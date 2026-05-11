import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/recipe_model.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;

  /// Generates a year-sequential ID like "2026001", "2026002", etc.
  /// Queries tbl_users for all IDs in the current year and increments the count.
  static Future<String> _generateUserID() async {
    final year = DateTime.now().year;
    final snap = await _db
        .collection('tbl_users')
        .where('userID', isGreaterThanOrEqualTo: '${year}000')
        .where('userID', isLessThan: '${year + 1}000')
        .get();
    final seq = (snap.docs.length + 1).toString().padLeft(3, '0');
    return '$year$seq';
  }

  static Future<void> createUser({
    required String uid,
    required String displayName,
    required String email,
    required String password,
    required double budget,
  }) async {
    final userID = await _generateUserID();
    await _db.collection('tbl_users').doc(uid).set({
      'userID': userID,
      'displayName': displayName,
      'email': email,
      'password': password,
      'budget': budget,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Saved recipes ───────────────────────────────────────────────────────

  static Future<String?> getCurrentUserID() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('tbl_users').doc(uid).get();
    return doc.data()?['userID']?.toString();
  }

  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('tbl_users').doc(uid).get();
    return doc.data();
  }

  static Future<int> _nextSavedRecipeID() async {
    final snap = await _db.collection('tbl_savedrecipes').get();
    return snap.docs.length + 1;
  }

  static Future<void> saveRecipe({
    required String recipeId,
    required String userId,
  }) async {
    final savedId = await _nextSavedRecipeID();
    await _db.collection('tbl_savedrecipes').add({
      'saved_recipe_id': savedId,
      'recipe_id': recipeId,
      'user_id': userId,
    });
  }

  static Future<void> unsaveRecipe({
    required String recipeId,
    required String userId,
  }) async {
    final snap = await _db
        .collection('tbl_savedrecipes')
        .where('recipe_id', isEqualTo: recipeId)
        .where('user_id', isEqualTo: userId)
        .get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  static Stream<Set<String>> savedRecipeIDsStream(String userId) {
    return _db
        .collection('tbl_savedrecipes')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => (doc.data()['recipe_id'] ?? '').toString())
            .toSet());
  }

  // ── Recipes ─────────────────────────────────────────────────────────────

  static Stream<List<RecipeModel>> recipesStream() {
    return _db
        .collection('tbl_recipes')
        .orderBy('title')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => RecipeModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
