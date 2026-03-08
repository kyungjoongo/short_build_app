import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import '../providers/shorts_provider.dart';
import '../models/short_script.dart';
import 'package:video_player/video_player.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _selectedScene = 0;
  VideoPlayerController? _controller;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadScene(0));
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _loadScene(int index) async {
    final script = context.read<ShortsProvider>().currentScript;
    if (script == null) return;
    final url = script.scenes[index].videoUrl;
    if (url == null) return;

    setState(() => _isInitializing = true);
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      _controller!.setLooping(true);
      _controller!.play();
    } catch (_) {}
    if (mounted) setState(() => _isInitializing = false);
  }

  void _shareVideo(String url) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final encoded = Uri.encodeComponent(url);
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.share_rounded, color: Color(0xFF6C63FF), size: 20),
                  SizedBox(width: 8),
                  Text('공유하기',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _shareOption(
                icon: Icons.alternate_email_rounded,
                label: 'Threads',
                color: Colors.white,
                onTap: () => launchUrl(
                    Uri.parse('https://www.threads.net/intent/post?text=$encoded'),
                    mode: LaunchMode.externalApplication),
              ),
              _shareOption(
                icon: Icons.close_rounded,
                label: 'X (Twitter)',
                color: Colors.white,
                onTap: () => launchUrl(
                    Uri.parse('https://twitter.com/intent/tweet?url=$encoded'),
                    mode: LaunchMode.externalApplication),
              ),
              _shareOption(
                icon: Icons.facebook_rounded,
                label: 'Facebook',
                color: const Color(0xFF1877F2),
                onTap: () => launchUrl(
                    Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encoded'),
                    mode: LaunchMode.externalApplication),
              ),
              _shareOption(
                icon: Icons.link_rounded,
                label: '링크 복사',
                color: Colors.grey,
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: url));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('링크가 복사되었습니다'),
                        backgroundColor: Colors.green));
                  }
                },
              ),
              _shareOption(
                icon: Icons.open_in_new_rounded,
                label: '새 탭에서 열기',
                color: Colors.orange,
                onTap: () => launchUrl(Uri.parse(url),
                    mode: LaunchMode.externalApplication),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _shareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
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
        title: const Text('완성된 쇼츠',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (script != null)
            IconButton(
              icon: const Icon(Icons.share_rounded, color: Colors.white),
              onPressed: () {
                final url = script.scenes[_selectedScene].videoUrl;
                if (url != null) _shareVideo(url);
              },
            ),
        ],
      ),
      body: script == null
          ? const Center(
              child: Text('결과 없음', style: TextStyle(color: Colors.white)))
          : Column(
              children: [
                // 비디오 플레이어
                Expanded(
                  flex: 3,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        child: _isInitializing || _controller == null
                            ? const Center(child: CircularProgressIndicator(
                                color: Color(0xFF6C63FF)))
                            : _controller!.value.isInitialized
                                ? AspectRatio(
                                    aspectRatio: _controller!.value.aspectRatio,
                                    child: VideoPlayer(_controller!),
                                  )
                                : const Center(
                                    child: Icon(Icons.error_rounded,
                                        color: Colors.red, size: 40)),
                      ),
                      // 자막 오버레이
                      Positioned(
                        bottom: 40,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            script.scenes[_selectedScene].caption,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.3),
                          ),
                        ),
                      ),
                      // 재생/일시정지
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (_controller?.value.isPlaying ?? false) {
                              _controller?.pause();
                            } else {
                              _controller?.play();
                            }
                            setState(() {});
                          },
                          child: Container(
                            color: Colors.transparent,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 씬 선택 탭
                Container(
                  color: const Color(0xFF1E1E1E),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: script.scenes.asMap().entries.map((e) {
                      final isSelected = e.key == _selectedScene;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            setState(() => _selectedScene = e.key);
                            await _loadScene(e.key);
                          },
                          child: Container(
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey[700]!,
                              ),
                            ),
                            child: Text(
                              '씬 ${e.key + 1}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[500],
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                // 액션 버튼
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white24),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: const Text('다시 만들기'),
                          onPressed: () {
                            provider.reset();
                            Navigator.of(context).popUntil(
                                (r) => r.isFirst);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.share_rounded,
                              color: Colors.white, size: 18),
                          label: const Text('공유하기',
                              style: TextStyle(color: Colors.white)),
                          onPressed: () {
                            final url = script.scenes[_selectedScene].videoUrl;
                            if (url != null) _shareVideo(url);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
