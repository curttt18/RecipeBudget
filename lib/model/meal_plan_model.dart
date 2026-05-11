import 'package:cloud_firestore/cloud_firestore.dart';

class MealPlanModel {
  const MealPlanModel({
    required this.docId,
    required this.mealId,
    required this.planName,
    required this.planDetails,
    required this.notes,
    required this.schedule,
    required this.recipeIds,
    required this.userId,
  });

  final String docId;
  final String mealId;
  final String planName;
  final String planDetails;
  final String notes;
  final DateTime schedule;
  final List<String> recipeIds;
  final String userId;

  factory MealPlanModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return MealPlanModel(
      docId: docId,
      mealId: data['meal_id']?.toString() ?? '',
      planName: data['plan_name'] ?? '',
      planDetails: data['plan_details'] ?? '',
      notes: data['notes'] ?? '',
      schedule: (data['schedule'] as Timestamp?)?.toDate() ?? DateTime.now(),
      recipeIds: List<String>.from(data['recipe_id'] ?? []),
      userId: data['user_id']?.toString() ?? '',
    );
  }
}
