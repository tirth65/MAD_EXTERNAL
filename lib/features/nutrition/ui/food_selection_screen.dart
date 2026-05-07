import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/core/constants/food_database.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';

class FoodSelectionScreen extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  const FoodSelectionScreen({super.key, required this.selectedDate});

  @override
  ConsumerState<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends ConsumerState<FoodSelectionScreen> {
  String _searchQuery = '';
  MealType _selectedType = MealType.breakfast;
  final TextEditingController _quantityController = TextEditingController(text: '100');

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredFoods = defaultFoodDatabase.where((food) => 
      food.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Meal Type Selector
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: MealType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(type.name.toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = type);
                      },
                      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryGreen,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search foods...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFoods.length,
                itemBuilder: (context, index) {
                  final food = filteredFoods[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(food.name),
                      subtitle: Text('${food.caloriesPer100g} kcal per 100g'),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: AppTheme.primaryGreen),
                        onPressed: () => _showAddDialog(context, food),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, FoodItem food) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${food.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity (grams)',
                suffixText: 'g',
              ),
              onChanged: (val) => setState(() {}), // Update totals on change
            ),
            const SizedBox(height: 12),
            _buildNutrientRow('Calories', (double.tryParse(_quantityController.text) ?? 0) * food.caloriesPer100g / 100, 'kcal'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final qty = double.tryParse(_quantityController.text) ?? 100.0;
              
              final meal = MealItem(
                name: food.name,
                calories: (qty * food.caloriesPer100g / 100),
                protein: (qty * food.proteinPer100g / 100),
                carbs: (qty * food.carbsPer100g / 100),
                fats: (qty * food.fatsPer100g / 100),
                quantity: qty,
                type: _selectedType,
                date: widget.selectedDate,
              );
              
              ref.read(mealsProvider.notifier).addMeal(meal);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to tracking screen
            },
            child: const Text('Add to Log'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text('${value.toInt()} $unit', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }
}
