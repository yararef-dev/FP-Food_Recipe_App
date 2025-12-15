import 'package:flutter/material.dart';
import 'package:food_recipes/screens/categories_screen.dart';

import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/meal_card.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Meal> meals = [];
  List<Meal> filteredMeals = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  int _selectedBottomIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  void fetchMeals() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final data = await ApiService.getAllMeals();
      if (!mounted) return;

      setState(() {
        meals = data;
        filteredMeals = meals;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      debugPrint("Error fetching meals: $e");
    }
  }

  void filterMeals(String query) {
    final lowerQuery = query.toLowerCase();
    setState(() {
      filteredMeals = meals
          .where((meal) => meal.name.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Recipes'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: filterMeals,
                  ),
                ),
                Expanded(
                  child: filteredMeals.isEmpty
                      ? Center(child: Text('No Recipes found'))
                      : ListView.builder(
                          itemCount: filteredMeals.length,
                          itemBuilder: (context, index) {
                            return MealCard(meal: filteredMeals[index]);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemSelected: (index) {
          if (index == _selectedBottomIndex) return;

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => FavoritesScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CategoriesScreen()),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
