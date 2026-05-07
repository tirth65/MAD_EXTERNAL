class FoodItem {
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final String unit;

  const FoodItem({
    required this.name,
    required this.caloriesPer100g,
    this.proteinPer100g = 0,
    this.carbsPer100g = 0,
    this.fatsPer100g = 0,
    this.unit = 'g',
  });
}

const List<FoodItem> defaultFoodDatabase = [
  FoodItem(name: 'Apple', caloriesPer100g: 52, carbsPer100g: 14, proteinPer100g: 0.3, fatsPer100g: 0.2),
  FoodItem(name: 'Banana', caloriesPer100g: 89, carbsPer100g: 23, proteinPer100g: 1.1, fatsPer100g: 0.3),
  FoodItem(name: 'Chicken Breast', caloriesPer100g: 165, carbsPer100g: 0, proteinPer100g: 31, fatsPer100g: 3.6),
  FoodItem(name: 'Rice (Cooked)', caloriesPer100g: 130, carbsPer100g: 28, proteinPer100g: 2.7, fatsPer100g: 0.3),
  FoodItem(name: 'Egg (Boiled)', caloriesPer100g: 155, carbsPer100g: 1.1, proteinPer100g: 13, fatsPer100g: 11),
  FoodItem(name: 'Oats', caloriesPer100g: 389, carbsPer100g: 66, proteinPer100g: 17, fatsPer100g: 7),
  FoodItem(name: 'Milk (Full Fat)', caloriesPer100g: 61, carbsPer100g: 4.8, proteinPer100g: 3.2, fatsPer100g: 3.3),
  FoodItem(name: 'Salmon', caloriesPer100g: 208, carbsPer100g: 0, proteinPer100g: 20, fatsPer100g: 13),
  FoodItem(name: 'Broccoli', caloriesPer100g: 34, carbsPer100g: 7, proteinPer100g: 2.8, fatsPer100g: 0.4),
  FoodItem(name: 'Greek Yogurt', caloriesPer100g: 59, carbsPer100g: 3.6, proteinPer100g: 10, fatsPer100g: 0.4),
];
