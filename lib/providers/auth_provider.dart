import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class AuthProvider extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isSignedIn => _userModel != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get userModel => _userModel;
  String get uid => _userModel?.uid ?? '';
  String get displayName => _userModel?.displayName ?? '';
  String get email => _userModel?.email ?? '';
  String get photoUrl => _userModel?.photoUrl ?? '';
  double get credits => _userModel?.credits ?? 0;

  AuthProvider() {
    _init();
  }

  void _init() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (user != null) {
        await _loadUser(user.uid);
      } else {
        _userModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    final user = await FirestoreService.getUser(uid);
    _userModel = user;
    notifyListeners();
  }

  Future<bool> signInWithTestAccount() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      User? user;
      try {
        final result = await FirebaseAuth.instance.signInAnonymously();
        user = result.user;
      } catch (_) {}

      final uid = user?.uid ?? 'test_user_uid_${DateTime.now().millisecondsSinceEpoch}';

      final userModel = UserModel(
        uid: uid,
        email: 'test@example.com',
        displayName: '테스트 유저',
        photoUrl: '',
        credits: 99.0, // 테스트 모드 넉넉한 크레딧
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      try {
        await FirestoreService.createOrUpdateUser(userModel);
      } catch (_) {}

      _userModel = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = result.user;
      if (user == null) throw Exception('Sign in failed');

      // 유저 생성 or 업데이트
      var userModel = await FirestoreService.getUser(user.uid);
      if (userModel == null) {
        userModel = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL ?? '',
          credits: 5.0, // 신규 가입 보너스
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      } else {
        userModel = userModel.copyWith();
      }
      await FirestoreService.createOrUpdateUser(userModel);
      _userModel = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    _userModel = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> deductCredits(double amount) async {
    if (_userModel == null) return false;
    final ok = await FirestoreService.deductCredits(_userModel!.uid, amount);
    if (ok) {
      _userModel = _userModel!.copyWith(credits: _userModel!.credits - amount);
      notifyListeners();
    }
    return ok;
  }

  Future<void> refreshCredits() async {
    if (_userModel == null) return;
    final fresh = await FirestoreService.getUser(_userModel!.uid);
    if (fresh != null) {
      _userModel = fresh;
      notifyListeners();
    }
  }
}
