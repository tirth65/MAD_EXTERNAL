import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:smart_meal_planner/features/settings/models/goal_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_meal_planner/features/nutrition/ui/daily_tracking_screen.dart';
import 'package:smart_meal_planner/features/meal_planning/ui/meal_planning_screen.dart';
import 'package:smart_meal_planner/features/nutrition/ui/food_database_screen.dart';
import 'package:smart_meal_planner/features/analytics/ui/analytics_dashboard_screen.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';
import 'package:smart_meal_planner/features/nutrition/ui/search_filter_screen.dart';

import 'package:smart_meal_planner/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Adapters
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(MealItemAdapter());
  Hive.registerAdapter(NutritionGoalAdapter());
  
  // Open Boxes
  await Hive.openBox<MealItem>('meals');
  await Hive.openBox<NutritionGoal>('goals');

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Auto-sync existing data to Cloud
    final container = ProviderContainer();
    final meals = container.read(mealsProvider);
    final firebase = container.read(firebaseServiceProvider);
    for (final meal in meals) {
      await firebase.syncMeal(meal);
    }
    debugPrint('Initial cloud sync completed');
    
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: SmartMealPlannerApp(),
    ),
  );
}

final isMobileViewProvider = StateProvider<bool>((ref) => true);

class SmartMealPlannerApp extends ConsumerWidget {
  const SmartMealPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobileView = ref.watch(isMobileViewProvider);

    return MaterialApp(
      title: 'Smart Meal Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        return Scaffold(
          backgroundColor: isMobileView ? const Color(0xFF1A1A1A) : Colors.white,
          body: Stack(
            children: [
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  width: isMobileView ? 400 : size.width,
                  height: isMobileView ? 820 : size.height,
                  decoration: isMobileView ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Colors.black, width: 12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ) : null,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: isMobileView ? 40 : 0),
                        child: ClipRRect(
                          borderRadius: isMobileView ? BorderRadius.circular(38) : BorderRadius.zero,
                          child: child,
                        ),
                      ),
                      if (isMobileView) ...[
                        // Notch
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 160,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        // Home Bar
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            width: 120,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 30,
                child: GestureDetector(
                  onTap: () => ref.read(isMobileViewProvider.notifier).state = !isMobileView,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMobileView ? Icons.desktop_windows : Icons.phone_android,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isMobileView ? 'Desktop Mode' : 'Mobile View',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}



class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DailyTrackingScreen(),
    const MealPlanningScreen(),
    const FoodDatabaseScreen(),
    const AnalyticsDashboardScreen(),
    const SearchFilterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Daily'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Food'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Analytics'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
        ],
      ),
    );
  }
}

