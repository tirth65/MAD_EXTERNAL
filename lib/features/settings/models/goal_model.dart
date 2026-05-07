import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 2)
class NutritionGoal extends HiveObject {
  @HiveField(0)
  final double targetCalories;
  
  @HiveField(1)
  final double? targetProtein;
  
  @HiveField(2)
  final double? targetCarbs;
  
  @HiveField(3)
  final double? targetFats;

  NutritionGoal({
    required this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFats,
  });
}
