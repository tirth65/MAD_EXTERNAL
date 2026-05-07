import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'meal_model.g.dart';

@HiveType(typeId: 0)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snacks,
}

@HiveType(typeId: 1)
class MealItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final double calories;
  
  @HiveField(3)
  final double quantity; // e.g., grams or count
  
  @HiveField(4)
  final MealType type;
  
  @HiveField(5)
  final DateTime date;

  @HiveField(6)
  final double protein;

  @HiveField(7)
  final double carbs;

  @HiveField(8)
  final double fats;

  MealItem({
    String? id,
    required this.name,
    required this.calories,
    required this.quantity,
    required this.type,
    required this.date,
    this.protein = 0,
    this.carbs = 0,
    this.fats = 0,
  }) : id = id ?? const Uuid().v4();
}
