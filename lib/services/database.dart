import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/meal_plan_model.dart';
import '../model/recipe_model.dart';

class DatabaseService {
  static final _db = FirebaseFirestore.instance;

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

  static Future<void> ensureGoogleUser({
    required String uid,
    required String displayName,
    required String email,
  }) async {
    final doc = await _db.collection('tbl_users').doc(uid).get();
    if (!doc.exists) {
      await createUser(
        uid: uid,
        displayName: displayName,
        email: email,
        password: '',
        budget: 0,
      );
    }
  }

  static Future<void> updateUserPassword(String newPassword) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('tbl_users').doc(uid).update({'password': newPassword});
  }

  static Future<void> updateBudget(double budget) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _db.collection('tbl_users').doc(uid).update({'budget': budget});
  }

  static Future<void> updateUserProfile({
    String? displayName,
    String? email,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (email != null) updates['email'] = email;
    if (updates.isNotEmpty) {
      await _db.collection('tbl_users').doc(uid).update(updates);
    }
    if (displayName != null) {
      await FirebaseAuth.instance.currentUser?.updateDisplayName(displayName);
    }
  }


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

  static Stream<Map<String, dynamic>?> userDataStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('tbl_users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.data());
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


  static Future<String> _generateMealID() async {
    final year = DateTime.now().year;
    final snap = await _db
        .collection('tbl_mealplans')
        .where('meal_id', isGreaterThanOrEqualTo: '${year}000')
        .where('meal_id', isLessThan: '${year + 1}000')
        .get();
    final seq = (snap.docs.length + 1).toString().padLeft(3, '0');
    return '$year$seq';
  }

  static Future<void> createMealPlan({
    required String userId,
    required String planName,
    required String planDetails,
    required String notes,
    required DateTime schedule,
    required List<String> recipeIds,
  }) async {
    final mealId = await _generateMealID();
    await _db.collection('tbl_mealplans').add({
      'meal_id': mealId,
      'plan_name': planName,
      'plan_details': planDetails,
      'notes': notes,
      'schedule': Timestamp.fromDate(schedule),
      'recipe_id': recipeIds,
      'user_id': userId,
    });
  }

  static Stream<List<MealPlanModel>> mealPlansStream(String userId) {
    return _db
        .collection('tbl_mealplans')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snap) {
          final plans = snap.docs
              .map((doc) => MealPlanModel.fromFirestore(doc.data(), doc.id))
              .toList();
          plans.sort((a, b) => a.schedule.compareTo(b.schedule));
          return plans;
        });
  }

  static Future<void> deleteMealPlan(String docId) async {
    await _db.collection('tbl_mealplans').doc(docId).delete();
  }


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
