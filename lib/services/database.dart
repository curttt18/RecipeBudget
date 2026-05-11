import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;

  static Future<void> createUser({
    required String uid,
    required String name,
    required String email,
    required double budget,
  }) async {
    await _db.collection('users_tbl').doc(uid).set({
      'name': name,
      'email': email,
      'global_budget': budget,
      'saved_recipes': [],
      'meal_plans': [],
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
