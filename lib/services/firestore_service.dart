import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../models/user_model.dart';
import '../models/short_script.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ─── 유저 ──────────────────────────────────────────────
  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection(Constants.usersCollection).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  static Future<void> createOrUpdateUser(UserModel user) async {
    await _db.collection(Constants.usersCollection).doc(user.uid).set(
      user.toFirestore(),
      SetOptions(merge: true),
    );
  }

  static Future<bool> deductCredits(String uid, double amount) async {
    try {
      await _db.runTransaction((tx) async {
        final ref = _db.collection(Constants.usersCollection).doc(uid);
        final snap = await tx.get(ref);
        if (!snap.exists) throw Exception('User not found');
        final current = (snap.data()!['credits'] ?? 0).toDouble();
        if (current < amount) throw Exception('Insufficient credits');
        tx.update(ref, {'credits': current - amount});
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── 쇼츠 ──────────────────────────────────────────────
  static Future<String> saveShort({
    required String userId,
    required ShortScript script,
  }) async {
    final doc = await _db.collection(Constants.shortsCollection).add({
      ...script.toMap(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Stream<List<ShortScript>> getUserShorts(String userId) {
    return _db
        .collection(Constants.shortsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        return ShortScript.fromJson(
          id: doc.id,
          topic: data['topic'] ?? '',
          json: data,
        );
      }).toList();
    });
  }
}
