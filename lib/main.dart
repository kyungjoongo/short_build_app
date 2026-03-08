import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/shorts_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ShortsAIApp());
}

class ShortsAIApp extends StatelessWidget {
  const ShortsAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ShortsProvider>(
          create: (_) => ShortsProvider(),
          update: (_, auth, provider) {
            final p = provider ?? ShortsProvider();
            p.setAuthProvider(auth);
            return p;
          },
        ),
      ],
      child: MaterialApp(
        title: 'ShortsAI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF6C63FF),
            secondary: Color(0xFFFF6584),
            surface: Color(0xFF1E1E1E),
          ),
          scaffoldBackgroundColor: const Color(0xFF0F0F0F),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
