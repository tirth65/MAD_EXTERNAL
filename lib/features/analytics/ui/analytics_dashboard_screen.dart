import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(mealsProvider);
    final goal = ref.watch(dailyGoalProvider);
    
    // Calculate last 7 days data
    final chartData = _generateChartData(ref);

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeeklyTrendCard(context, chartData, goal?.targetCalories ?? 2000),
            const SizedBox(height: 24),
            Text('Goal Achievement', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildGoalSummaryCard(context, ref),
            const SizedBox(height: 24),
            Text('Insights', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _buildInsightCard(
              context, 
              'Consistency is key!', 
              'You hit your calorie goal 5 out of the last 7 days. Keep it up!',
              Icons.trending_up,
              AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyTrendCard(BuildContext context, List<BarChartGroupData> data, double target) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Calorie Trend', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: target * 1.5,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(DateFormat('E').format(date)[0], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: data,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSummaryCard(BuildContext context, WidgetRef ref) {
    final goal = ref.watch(dailyGoalProvider);
    final meals = ref.watch(mealsProvider.notifier).getMealsForDate(DateTime.now());
    
    final targetCal = goal?.targetCalories ?? 2000;
    final targetProtein = goal?.targetProtein ?? 150;
    
    final currentCal = meals.fold(0.0, (sum, m) => sum + m.calories);
    final currentProtein = meals.fold(0.0, (sum, m) => sum + m.protein);

    final calProgress = (currentCal / targetCal).clamp(0.0, 1.0);
    final proteinProgress = (currentProtein / targetProtein).clamp(0.0, 1.0);
    final overallProgress = (calProgress + proteinProgress) / 2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildProgressCircle(context, 'Calories', calProgress, AppTheme.primaryGreen),
            _buildProgressCircle(context, 'Protein', proteinProgress, Colors.blue),
            _buildProgressCircle(context, 'Overall', overallProgress, AppTheme.energyOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCircle(BuildContext context, String label, double progress, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 10, color: AppTheme.textLight)),
      ],
    );
  }

  Widget _buildInsightCard(BuildContext context, String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                Text(desc, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateChartData(WidgetRef ref) {
    final notifier = ref.read(mealsProvider.notifier);
    return List.generate(7, (index) {
      final date = DateTime.now().subtract(Duration(days: 6 - index));
      final dayMeals = notifier.getMealsForDate(date);
      final total = dayMeals.fold(0.0, (sum, m) => sum + m.calories);
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            color: AppTheme.primaryGreen,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
