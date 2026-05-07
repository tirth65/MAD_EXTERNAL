import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/settings/models/goal_model.dart';

final mealsProvider = StateNotifierProvider<MealsNotifier, List<MealItem>>((ref) {
  return MealsNotifier();
});

class MealsNotifier extends StateNotifier<List<MealItem>> {
  MealsNotifier() : super([]) {
    _loadMeals();
  }

  void _loadMeals() {
    final box = Hive.box<MealItem>('meals');
    state = box.values.toList();
  }

  Future<void> addMeal(MealItem meal) async {
    final box = Hive.box<MealItem>('meals');
    await box.add(meal);
    state = [...state, meal];
  }

  Future<void> deleteMeal(String id) async {
    final box = Hive.box<MealItem>('meals');
    final index = box.values.toList().indexWhere((m) => m.id == id);
    if (index != -1) {
      await box.deleteAt(index);
      state = state.where((m) => m.id != id).toList();
    }
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
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<NutritionGoal?> {
  GoalNotifier() : super(null) {
    _loadGoal();
  }

  void _loadGoal() {
    final box = Hive.box<NutritionGoal>('goals');
    if (box.isNotEmpty) {
      state = box.getAt(0);
    } else {
      // Set a default goal if none exists
      final defaultGoal = NutritionGoal(targetCalories: 2000, targetProtein: 150, targetCarbs: 200, targetFats: 70);
      box.add(defaultGoal);
      state = defaultGoal;
    }
  }

  Future<void> updateGoal(NutritionGoal goal) async {
    final box = Hive.box<NutritionGoal>('goals');
    await box.putAt(0, goal);
    state = goal;
  }
}
