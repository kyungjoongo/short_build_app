import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // 로고
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 24),
              const Text(
                'AI 쇼츠를\n자동으로 만드세요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '토픽 하나로 바이럴 쇼츠 완성.\n마케터, 크리에이터를 위한 AI 도구.',
                style: TextStyle(color: Colors.grey[400], fontSize: 16, height: 1.5),
              ),
              const Spacer(flex: 3),
              // 기능 소개
              _FeatureRow(icon: Icons.bolt_rounded, text: '10초 안에 스크립트 자동 생성'),
              const SizedBox(height: 12),
              _FeatureRow(icon: Icons.videocam_rounded, text: 'AI가 씬별 비디오 자동 제작'),
              const SizedBox(height: 12),
              _FeatureRow(icon: Icons.share_rounded, text: 'SNS 즉시 공유'),
              const Spacer(flex: 2),
              // 로그인 버튼
              Consumer<AuthProvider>(builder: (ctx, auth, _) {
                if (auth.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    if (auth.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(auth.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                        label: const Text('Google로 시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          final ok = await auth.signInWithGoogle();
                          if (ok && ctx.mounted) {
                            Navigator.of(ctx).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.bug_report_rounded, size: 24),
                        label: const Text('테스트 모드로 시작하기',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        onPressed: () async {
                          final ok = await auth.signInWithTestAccount();
                          if (ok && ctx.mounted) {
                            Navigator.of(ctx).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        ),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 15)),
      ],
    );
  }
}
