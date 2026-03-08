import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/shorts_provider.dart';
import '../providers/auth_provider.dart';
import '../constants.dart';
import 'result_screen.dart';

class ScriptScreen extends StatefulWidget {
  const ScriptScreen({super.key});

  @override
  State<ScriptScreen> createState() => _ScriptScreenState();
}

class _ScriptScreenState extends State<ScriptScreen> {
  int _selectedDuration = 5;
  final _imagePicker = ImagePicker();

  Future<void> _pickImageForScene(int sceneIndex) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    context.read<ShortsProvider>().attachImageToScene(sceneIndex, picked.path);
  }

  void _clearImageForScene(int sceneIndex) {
    context.read<ShortsProvider>().clearImageFromScene(sceneIndex);
  }

  Future<void> _pickPersonModelImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    context.read<ShortsProvider>().setPersonModelImage(picked.path);
  }

  Future<void> _onGenerateVideos() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ShortsProvider>();
    final script = provider.currentScript;
    if (script == null) return;

    final totalCost = Constants.videoCreditCost * script.scenes.length;
    if (auth.credits < totalCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('크레딧이 부족합니다. 필요: $totalCost, 보유: ${auth.credits}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 크레딧 차감
    await auth.deductCredits(totalCost);

    // 비디오 생성
    await provider.generateVideos(duration: _selectedDuration);

    if (!mounted) return;
    if (provider.state == ShortsState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '오류'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (provider.isDone) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShortsProvider>();
    final script = provider.currentScript;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('생성된 스크립트',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: script == null
          ? const Center(
              child: Text('스크립트 없음',
                  style: TextStyle(color: Colors.white)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 훅
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.title_rounded,
                                color: Color(0xFF6C63FF), size: 18),
                            const SizedBox(width: 6),
                            const Text('제목',
                                style: TextStyle(
                                    color: Color(0xFF6C63FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(script.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Color(0xFFFF6584), size: 18),
                            const SizedBox(width: 6),
                            const Text('훅 (첫 2초)',
                                style: TextStyle(
                                    color: Color(0xFFFF6584),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('"${script.hook}"',
                            style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 15,
                                fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 인물 모델 선택 섹션
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: provider.personModelImagePath != null
                            ? const Color(0xFFFF6584).withOpacity(0.5)
                            : Colors.transparent,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_pin_rounded,
                                color: Color(0xFFFF6584), size: 20),
                            const SizedBox(width: 8),
                            const Text('모델 선택',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
                            const Spacer(),
                            if (provider.personModelImagePath != null)
                              GestureDetector(
                                onTap: () => provider.clearPersonModelImage(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('제거',
                                      style: TextStyle(
                                          color: Colors.red, fontSize: 11)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '인물 사진을 업로드하면 모든 씬에 해당 인물이 등장합니다',
                          style: TextStyle(color: Colors.grey[500], fontSize: 11),
                        ),
                        const SizedBox(height: 12),
                        if (provider.personModelImagePath != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(provider.personModelImagePath!),
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Center(
                            child: Text('인물 모델 설정됨',
                                style: TextStyle(
                                    color: Color(0xFFFF6584),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ] else
                          GestureDetector(
                            onTap: provider.isGeneratingVideo
                                ? null
                                : _pickPersonModelImage,
                            child: Container(
                              width: double.infinity,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F0F0F),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey[700]!),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo_outlined,
                                      color: Colors.grey[500], size: 24),
                                  const SizedBox(height: 6),
                                  Text('인물 사진 업로드',
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('씬 구성',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  // 씬 카드들
                  ...script.scenes.asMap().entries.map((entry) {
                    final i = entry.key;
                    final scene = entry.value;
                    final isGenerating = provider.isGeneratingVideo &&
                        provider.currentSceneIndex == i;
                    final isDone = scene.videoUrl != null;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isGenerating
                                ? const Color(0xFF6C63FF)
                                : isDone
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text('${scene.number}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text('씬',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                const Spacer(),
                                if (isGenerating)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF6C63FF)),
                                  )
                                else if (isDone)
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.green, size: 18),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _LabelRow(label: '자막', text: scene.caption),
                            const SizedBox(height: 8),
                            _LabelRow(label: '나레이션', text: scene.narration),
                            const SizedBox(height: 8),
                            _LabelRow(
                                label: 'AI 프롬프트',
                                text: scene.visualPrompt,
                                dimmed: true),
                            const SizedBox(height: 10),
                            // 이미지 첨부
                            GestureDetector(
                              onTap: provider.isGeneratingVideo
                                  ? null
                                  : () => _pickImageForScene(i),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: scene.imagePath != null
                                      ? const Color(0xFF6C63FF)
                                          .withOpacity(0.2)
                                      : const Color(0xFF0F0F0F),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: scene.imagePath != null
                                        ? const Color(0xFF6C63FF)
                                        : Colors.grey[700]!,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      scene.imagePath != null
                                          ? Icons.image_rounded
                                          : Icons.add_photo_alternate_outlined,
                                      color: scene.imagePath != null
                                          ? const Color(0xFF6C63FF)
                                          : Colors.grey[500],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        scene.imagePath != null
                                            ? '이미지 첨부됨'
                                            : '이미지 첨부 (선택)',
                                        style: TextStyle(
                                          color: scene.imagePath != null
                                              ? const Color(0xFF6C63FF)
                                              : Colors.grey[500],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    if (scene.imagePath != null)
                                      GestureDetector(
                                        onTap: () => _clearImageForScene(i),
                                        child: const Icon(Icons.close_rounded,
                                            color: Colors.grey, size: 16),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            if (scene.imagePath != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(scene.imagePath!),
                                    height: 80,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            // 인물 모델 적용 배지
                            if (provider.personModelImagePath != null &&
                                scene.imagePath == null &&
                                !isDone)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        const Color(0xFFFF6584).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_pin_rounded,
                                          color: Color(0xFFFF6584), size: 12),
                                      const SizedBox(width: 4),
                                      const Text('모델 사진 적용됨',
                                          style: TextStyle(
                                              color: Color(0xFFFF6584),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // CTA
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.campaign_rounded,
                            color: Color(0xFFFF6584), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(script.callToAction,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  // 재생 시간 선택
                  const Text('비디오 재생 시간 (단일 씬)',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Row(
                    children: [5, 10, 15].map((d) {
                      final isSelected = _selectedDuration == d;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!provider.isGeneratingVideo) {
                              setState(() => _selectedDuration = d);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFF1E1E1E),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey[800]!,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text('$d초',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[400],
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),
                  // 생성 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: provider.isGeneratingVideo ? null : _onGenerateVideos,
                      child: provider.isGeneratingVideo
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '씬 ${provider.currentSceneIndex + 1}/${script.scenes.length} 생성 중...',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.videocam_rounded,
                                    color: Colors.white, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  '비디오 생성하기 (${(Constants.videoCreditCost * script.scenes.length).toStringAsFixed(0)} 크레딧)',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}

class _LabelRow extends StatelessWidget {
  final String label;
  final String text;
  final bool dimmed;
  const _LabelRow(
      {required this.label, required this.text, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  color: dimmed ? Colors.grey[500] : Colors.grey[200],
                  fontSize: 13)),
        ),
      ],
    );
  }
}
