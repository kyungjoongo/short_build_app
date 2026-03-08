import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class VideoService {
  static const String _falBase = 'https://queue.fal.run';
  static const String _falStatus = 'https://queue.fal.run';

  // fal.ai 텍스트→비디오 생성 (비동기 큐 방식)
  Future<Map<String, dynamic>> generateVideoFromText(String prompt, {int duration = 5}) async {
    final modelPath = Constants.falTextToVideoModel;
    final url = '$_falBase/$modelPath';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Key ${Constants.falApiToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': '$prompt. Cinematic quality, short clip.',
        'aspect_ratio': '9:16',
        'duration': duration,
        'resolution': '720p',
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('fal.ai error: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 폴링으로 상태 확인
  Future<Map<String, dynamic>> checkStatus(String statusUrl) async {
    print('fal.ai [checkStatus] GET url: $statusUrl');
    final response = await http.get(
      Uri.parse(statusUrl),
      headers: {'Authorization': 'Key ${Constants.falApiToken}'},
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      print('fal.ai [checkStatus] ERROR ${response.statusCode}: ${response.body}');
      throw Exception('Status check error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 완료된 결과 가져오기
  Future<Map<String, dynamic>> getResult(String responseUrl) async {
    print('fal.ai [getResult] GET url: $responseUrl');
    final response = await http.get(
      Uri.parse(responseUrl),
      headers: {'Authorization': 'Key ${Constants.falApiToken}'},
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      print('fal.ai [getResult] ERROR ${response.statusCode}: ${response.body}');
      throw Exception('Get result error: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 비디오 URL에서 바이트 다운로드
  Future<Uint8List> downloadFromUrl(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Download failed: ${response.statusCode}');
    }
    return response.bodyBytes;
  }

  // Firebase Storage에 비디오 업로드
  Future<String> uploadToFirebaseStorage(Uint8List bytes, String fileName) async {
    final ref = FirebaseStorage.instance
        .ref()
        .child('generated-shorts')
        .child(fileName);

    final metadata = SettableMetadata(contentType: 'video/mp4');
    final task = await ref.putData(bytes, metadata);
    return await task.ref.getDownloadURL();
  }

  // 로컬 이미지를 Firebase Storage에 업로드하여 public URL 반환 (fal.ai용)
  Future<String> uploadImageForFal(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final fileName = 'temp_input_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance
        .ref()
        .child('temp-inputs')
        .child(fileName);
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    final task = await ref.putData(bytes, metadata);
    return await task.ref.getDownloadURL();
  }

  // fal.ai image-to-video 생성 (이미지 + 프롬프트 → 비디오)
  Future<Map<String, dynamic>> generateVideoFromImage(
    String prompt,
    String imageUrl, {
    int duration = 5,
  }) async {
    final modelPath = Constants.falImageToVideoModel;
    final url = '$_falBase/$modelPath';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Key ${Constants.falApiToken}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': '$prompt. Cinematic quality, short clip.',
        'image_url': imageUrl,
        'aspect_ratio': '9:16',
        'duration': duration,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('fal.ai image-to-video error: ${response.statusCode} ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // 파일명 생성
  String generateFileName(int sceneNumber) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return 'scene_${sceneNumber}_$ts.mp4';
  }
}
