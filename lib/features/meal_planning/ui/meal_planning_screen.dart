import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/nutrition/ui/food_selection_screen.dart';
import 'package:intl/intl.dart';

class MealPlanningScreen extends ConsumerStatefulWidget {
  const MealPlanningScreen({super.key});

  @override
  ConsumerState<MealPlanningScreen> createState() => _MealPlanningScreenState();
}

class _MealPlanningScreenState extends ConsumerState<MealPlanningScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealsProvider);
    final plannedMeals = ref.read(mealsProvider.notifier).getMealsForDate(_selectedDate);
    final totalCalories = plannedMeals.fold(0.0, (sum, item) => sum + item.calories);

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 30)),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarStrip(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(totalCalories),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plan for ${DateFormat('MMM dd').format(_selectedDate)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodSelectionScreen(selectedDate: _selectedDate),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: plannedMeals.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: plannedMeals.length,
                            itemBuilder: (context, index) => _buildMealCard(plannedMeals[index]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14, // 2 weeks
        itemBuilder: (context, index) {
          final date = DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: index));
          final isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);
          
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryGreen : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date)[0],
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('d').format(date),
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double total) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Planned Calories', style: Theme.of(context).textTheme.bodySmall),
                  Text('${total.toInt()} kcal', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.primaryGreen)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(MealItem meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(meal.type), color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${meal.type.name.toUpperCase()} • ${meal.quantity.toInt()}g', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Text('${meal.calories.toInt()} kcal', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
            onPressed: () => ref.read(mealsProvider.notifier).deleteMeal(meal.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 48, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No meals planned for this day', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  IconData _getIcon(MealType type) {
    switch (type) {
      case MealType.breakfast: return Icons.wb_sunny;
      case MealType.lunch: return Icons.lunch_dining;
      case MealType.dinner: return Icons.nightlight_round;
      case MealType.snacks: return Icons.cookie;
    }
  }
}
