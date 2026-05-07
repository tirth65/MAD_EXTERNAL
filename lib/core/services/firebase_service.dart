import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/settings/models/goal_model.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;
  
  // Using a static ID for now since we don't have Auth implemented yet
  static const String _userId = 'default_user';

  // --- Meals Sync ---
  
  Future<void> syncMeal(MealItem meal) async {
    try {
      await _db.collection('users').doc(_userId).collection('meals').doc(meal.id).set({
        'name': meal.name,
        'calories': meal.calories,
        'protein': meal.protein,
        'carbs': meal.carbs,
        'fats': meal.fats,
        'quantity': meal.quantity,
        'type': meal.type.name,
        'date': Timestamp.fromDate(meal.date),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error syncing meal: $e');
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await _db.collection('users').doc(_userId).collection('meals').doc(mealId).delete();
    } catch (e) {
      debugPrint('Error deleting meal from cloud: $e');
    }
  }

  // --- Goals Sync ---

  Future<void> syncGoal(NutritionGoal goal) async {
    try {
      await _db.collection('users').doc(_userId).collection('goals').doc('daily_goal').set({
        'targetCalories': goal.targetCalories,
        'targetProtein': goal.targetProtein,
        'targetCarbs': goal.targetCarbs,
        'targetFats': goal.targetFats,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error syncing goal: $e');
    }
  }

  // --- Stream Data (Optional but good for real-time) ---
  
  Stream<List<MealItem>> getMealsStream() {
    return _db.collection('users').doc(_userId).collection('meals')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MealItem(
              id: doc.id,
              name: data['name'],
              calories: (data['calories'] as num).toDouble(),
              protein: (data['protein'] as num).toDouble(),
              carbs: (data['carbs'] as num).toDouble(),
              fats: (data['fats'] as num).toDouble(),
              quantity: (data['quantity'] as num).toDouble(),
              type: MealType.values.firstWhere((e) => e.name == data['type']),
              date: (data['date'] as Timestamp).toDate(),
            );
          }).toList();
        });
  }
}
