import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/shorts_provider.dart';
import 'script_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _topicController = TextEditingController();
  int _sceneCount = 3;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _onGenerate() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) return;

    final provider = context.read<ShortsProvider>();
    await provider.generateScript(topic, sceneCount: _sceneCount);

    if (!mounted) return;
    if (provider.state == ShortsState.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? '오류가 발생했습니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (provider.currentScript != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ScriptScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<ShortsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_fill_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('ShortsAI',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
          ],
        ),
        actions: [
          // 크레딧 표시
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF6C63FF), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded,
                    color: Color(0xFF6C63FF), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${auth.credits.toStringAsFixed(1)}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13),
                ),
              ],
            ),
          ),
          // 로그아웃
          PopupMenuButton<String>(
            color: const Color(0xFF1E1E1E),
            icon: CircleAvatar(
              radius: 16,
              backgroundImage: auth.photoUrl.isNotEmpty
                  ? NetworkImage(auth.photoUrl)
                  : null,
              backgroundColor: const Color(0xFF6C63FF),
              child: auth.photoUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 18)
                  : null,
            ),
            onSelected: (val) async {
              if (val == 'logout') {
                await auth.signOut();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'info',
                enabled: false,
                child: Text(auth.displayName,
                    style: const TextStyle(color: Colors.white70)),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('로그아웃', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // 메인 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '어떤 쇼츠를\n만들어드릴까요? 🎬',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '주제를 입력하면 AI가 스크립트부터 비디오까지 자동 완성',
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  // 입력 필드
                  TextField(
                    controller: _topicController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: '예: 한국 치킨 맛집 TOP 5\n예: 아이폰 16 vs 갤럭시 비교',
                      hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                      filled: true,
                      fillColor: const Color(0xFF0F0F0F),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _onGenerate(),
                  ),
                  const SizedBox(height: 16),
                  // 씬 개수 선택
                  Row(
                    children: [
                      Text('씬 개수',
                          style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      ...List.generate(3, (i) {
                        final count = i + 1;
                        final selected = _sceneCount == count;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => setState(() => _sceneCount = count),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: selected
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFF0F0F0F),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selected
                                      ? const Color(0xFF6C63FF)
                                      : Colors.grey[700]!,
                                ),
                              ),
                              child: Center(
                                child: Text('$count',
                                    style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : Colors.grey[400],
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 예시 칩
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '고양이 댄스 비디오 🐱',
                      '사이버펑크 서울 거리 🌃',
                      '환상적인 마법의 숲 🧚',
                      '화성에서의 눈부신 일출 🪐',
                    ].map((tag) => GestureDetector(
                      onTap: () {
                        _topicController.text = tag;
                        FocusScope.of(context).unfocus(); // 키보드 내리기
                        _onGenerate();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFF6C63FF).withOpacity(0.4)),
                        ),
                        child: Text(tag,
                            style: const TextStyle(
                                color: Color(0xFF6C63FF),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 20),
                  // 생성 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: provider.isGeneratingScript ? null : _onGenerate,
                      child: provider.isGeneratingScript
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('스크립트 생성 중...',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('스크립트 생성하기',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      '스크립트 1 크레딧 • 씬당 비디오 2 크레딧',
                      style: TextStyle(color: Colors.grey[600], fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // 사용 방법
            const Text('사용 방법',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _StepCard(step: '1', title: '주제 입력', desc: '만들고 싶은 쇼츠의 주제를 입력하세요'),
            const SizedBox(height: 10),
            _StepCard(step: '2', title: '스크립트 확인', desc: 'AI가 선택한 씬 개수로 스크립트를 생성해요'),
            const SizedBox(height: 10),
            _StepCard(step: '3', title: '비디오 생성', desc: 'AI가 각 씬을 자동으로 비디오로 만들어요'),
            const SizedBox(height: 10),
            _StepCard(step: '4', title: 'SNS 공유', desc: '완성된 쇼츠를 바로 공유하세요'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String desc;
  const _StepCard({required this.step, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFFFF6584)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(step,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
