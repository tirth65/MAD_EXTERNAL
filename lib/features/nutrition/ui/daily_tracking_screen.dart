import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/nutrition/ui/food_selection_screen.dart';
import 'package:smart_meal_planner/features/settings/ui/goal_setting_screen.dart';
import 'package:intl/intl.dart';

final waterIntakeProvider = StateProvider<int>((ref) => 0);

class DailyTrackingScreen extends ConsumerWidget {
  const DailyTrackingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final goal = ref.watch(dailyGoalProvider);
    final waterGlasses = ref.watch(waterIntakeProvider);
    
    final todayMeals = ref.read(mealsProvider.notifier).getMealsForDate(DateTime.now());
    final consumedCalories = todayMeals.fold(0.0, (sum, item) => sum + item.calories);
    final totalProtein = todayMeals.fold(0.0, (sum, item) => sum + item.protein);
    final totalCarbs = todayMeals.fold(0.0, (sum, item) => sum + item.carbs);
    final totalFats = todayMeals.fold(0.0, (sum, item) => sum + item.fats);

    final targetCalories = goal?.targetCalories ?? 2000.0;
    final remainingCalories = targetCalories - consumedCalories;
    final progress = (consumedCalories / targetCalories).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Daily Progress', style: Theme.of(context).textTheme.titleLarge),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCalorieCard(context, consumedCalories, targetCalories, remainingCalories, progress),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GoalSettingScreen()),
                      ),
                      icon: const Icon(Icons.edit_note, color: AppTheme.primaryGreen),
                      label: const Text(
                        'Change your daily goal',
                        style: TextStyle(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNutrientBreakdown(context, totalProtein, totalCarbs, totalFats),
                  const SizedBox(height: 24),
                  _buildHydrationTracker(context, ref, waterGlasses),
                  const SizedBox(height: 24),
                  Text('Today\'s Meals', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  if (todayMeals.isEmpty)
                    _buildEmptyState(context)
                  else
                    ...todayMeals.map((meal) => _buildMealTile(context, meal, ref)),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodSelectionScreen(selectedDate: DateTime.now())),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHydrationTracker(BuildContext context, WidgetRef ref, int glasses) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blue.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hydration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Goal: 8 glasses (2L)', style: TextStyle(color: Colors.blue[700], fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: List.generate(8, (index) {
                    final isFilled = index < glasses;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 8,
                          decoration: BoxDecoration(
                            color: isFilled ? Colors.blue : Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () => ref.read(waterIntakeProvider.notifier).state = (glasses + 1) % 9,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.local_drink, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientBreakdown(BuildContext context, double p, double c, double f) {
    return Row(
      children: [
        _buildNutrientBar(context, 'Protein', p, 150, Colors.blue),
        const SizedBox(width: 12),
        _buildNutrientBar(context, 'Carbs', c, 200, Colors.green),
        const SizedBox(width: 12),
        _buildNutrientBar(context, 'Fats', f, 70, Colors.amber),
      ],
    );
  }

  Widget _buildNutrientBar(BuildContext context, String label, double current, double target, Color color) {
    final progress = (current / target).clamp(0.0, 1.0);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${current.toInt()}g', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                color: color,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieCard(BuildContext context, double consumed, double target, double remaining, double progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Calories', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('${consumed.toInt()}', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppTheme.primaryGreen)),
                  Text('of ${target.toInt()} kcal', style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMiniStat(context, 'Remaining', '${remaining.toInt()}', AppTheme.energyOrange),
                      const SizedBox(width: 24),
                      _buildMiniStat(context, 'Burned', '320', Colors.blue), // Placeholder for burned
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.withOpacity(0.1),
                    color: AppTheme.primaryGreen,
                    strokeCap: StrokeCap.round,
                  ),
                  Center(
                    child: Text('${(progress * 100).toInt()}%', style: Theme.of(context).textTheme.titleLarge),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, color: color)),
      ],
    );
  }

  Widget _buildMealTile(BuildContext context, MealItem meal, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getMealIcon(meal.type), color: AppTheme.primaryGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16)),
                Text('${meal.type.name.toUpperCase()} • ${meal.quantity.toInt()}g', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${meal.calories.toInt()} kcal', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, color: AppTheme.primaryGreen)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                onPressed: () => ref.read(mealsProvider.notifier).deleteMeal(meal.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('No meals logged today', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Tap + to add your first meal', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return Icons.wb_sunny_outlined;
      case MealType.lunch: return Icons.lunch_dining_outlined;
      case MealType.dinner: return Icons.nightlight_round_outlined;
      case MealType.snacks: return Icons.cookie_outlined;
    }
  }
}
