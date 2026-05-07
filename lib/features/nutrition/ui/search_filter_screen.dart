import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_meal_planner/core/theme/app_theme.dart';
import 'package:smart_meal_planner/features/nutrition/providers/nutrition_provider.dart';
import 'package:smart_meal_planner/features/meal_planning/models/meal_model.dart';
import 'package:intl/intl.dart';

class SearchFilterScreen extends ConsumerStatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  ConsumerState<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends ConsumerState<SearchFilterScreen> {
  String _searchQuery = '';
  MealType? _filterType;
  DateTime? _filterDate;

  @override
  Widget build(BuildContext context) {
    final allMeals = ref.watch(mealsProvider);
    
    final filteredMeals = allMeals.where((meal) {
      final matchesSearch = meal.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == null || meal.type == _filterType;
      final matchesDate = _filterDate == null || 
          (meal.date.year == _filterDate!.year && 
           meal.date.month == _filterDate!.month && 
           meal.date.day == _filterDate!.day);
      
      return matchesSearch && matchesType && matchesDate;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.softWhite,
      appBar: AppBar(
        title: const Text('Search & Filter'),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          _buildFilterChips(),
          Expanded(
            child: filteredMeals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) => _buildResultTile(filteredMeals[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search logged meals...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          // Meal Type Filter
          _buildFilterButton(
            _filterType?.name.toUpperCase() ?? 'All Types',
            Icons.restaurant,
            () => _showTypePicker(),
          ),
          const SizedBox(width: 12),
          // Date Filter
          _buildFilterButton(
            _filterDate == null ? 'All Dates' : DateFormat('MMM dd').format(_filterDate!),
            Icons.calendar_today,
            () => _showDatePicker(),
          ),
          if (_filterType != null || _filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.redAccent),
              onPressed: () => setState(() {
                _filterType = null;
                _filterDate = null;
              }),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Flexible(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultTile(MealItem meal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(meal.name),
        subtitle: Text('${DateFormat('MMM dd').format(meal.date)} • ${meal.type.name.toUpperCase()}'),
        trailing: Text('${meal.calories.toInt()} kcal', style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 48, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text('No matches found', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showTypePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(title: Text('Select Meal Type', style: TextStyle(fontWeight: FontWeight.bold))),
          ...MealType.values.map((type) => ListTile(
            title: Text(type.name.toUpperCase()),
            onTap: () {
              setState(() => _filterType = type);
              Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) setState(() => _filterDate = date);
  }
}
