import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/settings/models/goal_model.dart';

import 'package:smart_meal_planner/core/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final mealsProvider = StateNotifierProvider<MealsNotifier, List<MealItem>>((ref) {
  return MealsNotifier(ref.read(firebaseServiceProvider));
});

class MealsNotifier extends StateNotifier<List<MealItem>> {
  final FirebaseService _firebaseService;
  
  MealsNotifier(this._firebaseService) : super([]) {
    _loadMeals();
  }

  void _loadMeals() {
    final box = Hive.box<MealItem>('meals');
    state = box.values.toList();
  }

  Future<void> addMeal(MealItem meal) async {
    // Save to Local Database (Hive)
    final box = Hive.box<MealItem>('meals');
    await box.add(meal);
    state = [...state, meal];
    
    // Sync to Cloud Database (Firebase)
    await _firebaseService.syncMeal(meal);
  }

  Future<void> deleteMeal(String id) async {
    // Delete from Local Database
    final box = Hive.box<MealItem>('meals');
    final index = box.values.toList().indexWhere((m) => m.id == id);
    if (index != -1) {
      await box.deleteAt(index);
      state = state.where((m) => m.id != id).toList();
    }
    
    // Delete from Cloud
    await _firebaseService.deleteMeal(id);
  }

  List<MealItem> getMealsForDate(DateTime date) {
    return state.where((m) => 
      m.date.year == date.year && 
      m.date.month == date.month && 
      m.date.day == date.day
    ).toList();
  }
}

final dailyGoalProvider = StateNotifierProvider<GoalNotifier, NutritionGoal?>((ref) {
  return GoalNotifier(ref.read(firebaseServiceProvider));
});

class GoalNotifier extends StateNotifier<NutritionGoal?> {
  final FirebaseService _firebaseService;

  GoalNotifier(this._firebaseService) : super(null) {
    _loadGoal();
  }

  void _loadGoal() {
    final box = Hive.box<NutritionGoal>('goals');
    if (box.isNotEmpty) {
      state = box.getAt(0);
    } else {
      final defaultGoal = NutritionGoal(targetCalories: 2000, targetProtein: 150, targetCarbs: 200, targetFats: 70);
      box.add(defaultGoal);
      state = defaultGoal;
    }
  }

  Future<void> updateGoal(NutritionGoal goal) async {
    final box = Hive.box<NutritionGoal>('goals');
    await box.putAt(0, goal);
    state = goal;
    
    // Sync to Cloud
    await _firebaseService.syncGoal(goal);
  }
}
