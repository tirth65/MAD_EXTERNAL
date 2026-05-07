import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';
import 'package:smart_meal_planner/features/settings/models/goal_model.dart';

class GoalSettingScreen extends ConsumerStatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  ConsumerState<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends ConsumerState<GoalSettingScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    final currentGoal = ref.read(dailyGoalProvider);
    _caloriesController = TextEditingController(text: currentGoal?.targetCalories.toInt().toString() ?? '2000');
    _proteinController = TextEditingController(text: currentGoal?.targetProtein?.toInt().toString() ?? '150');
    _carbsController = TextEditingController(text: currentGoal?.targetCarbs?.toInt().toString() ?? '200');
    _fatsController = TextEditingController(text: currentGoal?.targetFats?.toInt().toString() ?? '70');
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Goals'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              'Customize your daily targets to reach your fitness goals faster.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
            ),
            const SizedBox(height: 32),
            _buildGoalField(
              label: 'Target Calories',
              controller: _caloriesController,
              unit: 'kcal',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            _buildGoalField(
              label: 'Target Protein',
              controller: _proteinController,
              unit: 'g',
              icon: Icons.egg,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildGoalField(
              label: 'Target Carbs',
              controller: _carbsController,
              unit: 'g',
              icon: Icons.grain,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildGoalField(
              label: 'Target Fats',
              controller: _fatsController,
              unit: 'g',
              icon: Icons.opacity,
              color: Colors.amber,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _saveGoals,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Targets', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalField({
    required String label,
    required TextEditingController controller,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color),
            suffixText: unit,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter a value';
            if (double.tryParse(value) == null) return 'Enter a valid number';
            return null;
          },
        ),
      ],
    );
  }

  void _saveGoals() {
    if (_formKey.currentState!.validate()) {
      final newGoal = NutritionGoal(
        targetCalories: double.parse(_caloriesController.text),
        targetProtein: double.parse(_proteinController.text),
        targetCarbs: double.parse(_carbsController.text),
        targetFats: double.parse(_fatsController.text),
      );
      
      ref.read(dailyGoalProvider.notifier).updateGoal(newGoal);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goals updated successfully!'), backgroundColor: AppTheme.primaryGreen),
      );
      Navigator.pop(context);
    }
  }
}
