import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/short_script.dart';
import '../services/script_service.dart';
import '../services/video_service.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

enum ShortsState { idle, generatingScript, generatingVideo, done, error }

class ShortsProvider extends ChangeNotifier {
  final ScriptService _scriptService = ScriptService();
  final VideoService _videoService = VideoService();
  AuthProvider? _authProvider;

  ShortsState _state = ShortsState.idle;
  ShortScript? _currentScript;
  int _currentSceneIndex = 0;
  String? _errorMessage;
  List<ShortScript> _history = [];
  String? _personModelImagePath;

  // Getters
  ShortsState get state => _state;
  ShortScript? get currentScript => _currentScript;
  int get currentSceneIndex => _currentSceneIndex;
  String? get errorMessage => _errorMessage;
  List<ShortScript> get history => _history;
  String? get personModelImagePath => _personModelImagePath;
  bool get isGeneratingScript => _state == ShortsState.generatingScript;
  bool get isGeneratingVideo => _state == ShortsState.generatingVideo;
  bool get isDone => _state == ShortsState.done;

  void setAuthProvider(AuthProvider auth) {
    _authProvider = auth;
  }

  // ─── 스크립트 생성 ──────────────────────────────────────
  Future<void> generateScript(String topic, {int sceneCount = 3}) async {
    if (topic.trim().isEmpty) return;

    _state = ShortsState.generatingScript;
    _errorMessage = null;
    _currentScript = null;
    notifyListeners();

    try {
      final script = await _scriptService.generateScript(topic.trim(), sceneCount: sceneCount);
      _currentScript = script;
      _state = ShortsState.idle;
      notifyListeners();
    } catch (e) {
      _errorMessage = '스크립트 생성 실패: $e';
      _state = ShortsState.error;
      notifyListeners();
    }
  }

  // ─── 비디오 생성 ──────────────────────────────────────
  Future<void> generateVideos({int duration = 5}) async {
    if (_currentScript == null) return;

    _state = ShortsState.generatingVideo;
    _currentSceneIndex = 0;
    _errorMessage = null;
    notifyListeners();

    try {
      for (int i = 0; i < _currentScript!.scenes.length; i++) {
        _currentSceneIndex = i;
        notifyListeners();

        final scene = _currentScript!.scenes[i];
        // 우선순위: 씬 이미지 > 인물 모델 이미지 > 텍스트 전용
        final effectiveImagePath = scene.imagePath ?? _personModelImagePath;
        final videoUrl = await _generateOneScene(scene.visualPrompt, i + 1, duration: duration, imagePath: effectiveImagePath);
        _currentScript!.scenes[i].videoUrl = videoUrl;
        notifyListeners();
      }

      // Firestore 저장
      if (_authProvider != null && _authProvider!.isSignedIn) {
        await FirestoreService.saveShort(
          userId: _authProvider!.uid,
          script: _currentScript!,
        );
      }

      _state = ShortsState.done;
      notifyListeners();
    } catch (e) {
      _errorMessage = '비디오 생성 실패: $e';
      _state = ShortsState.error;
      notifyListeners();
    }
  }

  Future<String> _generateOneScene(String prompt, int sceneNum, {int duration = 5, String? imagePath}) async {
    // 1. fal.ai에 요청 제출
    Map<String, dynamic> result;
    if (imagePath != null) {
      final imageFile = File(imagePath);
      final imageUrl = await _videoService.uploadImageForFal(imageFile);
      result = await _videoService.generateVideoFromImage(prompt, imageUrl, duration: duration);
    } else {
      result = await _videoService.generateVideoFromText(prompt, duration: duration);
    }

    final requestId = result['request_id'] as String?;
    final statusUrl = result['status_url'] as String?;
    final responseUrl = result['response_url'] as String?;
    
    if (requestId == null || statusUrl == null || responseUrl == null) {
      // 즉시 완료된 경우 (또는 에러)
      return _extractVideoUrl(result);
    }

    // 2. 폴링으로 완료 대기 (최대 5분)
    for (int i = 0; i < 100; i++) {
      await Future.delayed(const Duration(seconds: 3));
      final status = await _videoService.checkStatus(statusUrl);
      final statusStr = status['status'] as String? ?? '';
      if (statusStr == 'COMPLETED') {
        final res = await _videoService.getResult(responseUrl);
        final url = _extractVideoUrl(res);
        // Firebase Storage 업로드
        final bytes = await _videoService.downloadFromUrl(url);
        final fileName = _videoService.generateFileName(sceneNum);
        return await _videoService.uploadToFirebaseStorage(bytes, fileName);
      } else if (statusStr == 'FAILED') {
        throw Exception('Video generation failed for scene $sceneNum');
      }
    }
    throw Exception('Timeout waiting for video generation');
  }

  String _extractVideoUrl(Map<String, dynamic> result) {
    final video = result['video'];
    if (video is Map) return video['url'] as String? ?? '';
    if (video is String) return video;
    final videos = result['videos'];
    if (videos is List && videos.isNotEmpty) {
      final first = videos.first;
      if (first is Map) return first['url'] as String? ?? '';
    }
    throw Exception('No video URL in result: $result');
  }

  // ─── 이미지 첨부 ──────────────────────────────────────
  void attachImageToScene(int index, String? imagePath) {
    if (_currentScript == null || index >= _currentScript!.scenes.length) return;
    final scene = _currentScript!.scenes[index];
    _currentScript!.scenes[index] = scene.copyWith(imagePath: imagePath);
    notifyListeners();
  }

  void clearImageFromScene(int index) {
    if (_currentScript == null || index >= _currentScript!.scenes.length) return;
    final scene = _currentScript!.scenes[index];
    _currentScript!.scenes[index] = SceneScript(
      number: scene.number,
      visualPrompt: scene.visualPrompt,
      caption: scene.caption,
      narration: scene.narration,
      videoUrl: scene.videoUrl,
      imagePath: null,
    );
    notifyListeners();
  }

  // ─── 인물 모델 ──────────────────────────────────────
  void setPersonModelImage(String? path) {
    _personModelImagePath = path;
    notifyListeners();
  }

  void clearPersonModelImage() {
    _personModelImagePath = null;
    notifyListeners();
  }

  // ─── 씬 편집 ──────────────────────────────────────────
  void editScene(int index, {String? caption, String? visualPrompt}) {
    if (_currentScript == null || index >= _currentScript!.scenes.length) return;
    final scene = _currentScript!.scenes[index];
    _currentScript!.scenes[index] = scene.copyWith(
      caption: caption,
      visualPrompt: visualPrompt,
    );
    notifyListeners();
  }

  void reset() {
    _state = ShortsState.idle;
    _currentScript = null;
    _currentSceneIndex = 0;
    _errorMessage = null;
    _personModelImagePath = null;
    notifyListeners();
  }
}
