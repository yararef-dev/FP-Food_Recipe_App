import 'package:flutter/material.dart';
import 'package:food_recipes/screens/categories_screen.dart';
import 'package:food_recipes/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'recipe_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Meal> favoriteMeals = [];
  bool isLoading = true;

  int _selectedBottomIndex = 2;

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favIds = prefs.getStringList('favorites') ?? [];

    List<Meal> meals = [];

    for (String id in favIds) {
      try {
        final data = await ApiService.getMealDetail(id);
        if (data.isNotEmpty) {
          meals.add(Meal.fromJson(data));
        }
      } catch (e) {
        print("Error loading meal with id $id: $e");
      }
    }

    setState(() {
      favoriteMeals = meals;
      isLoading = false;
    });
  }

  Future<void> removeFromFavorites(String mealId, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favIds = prefs.getStringList('favorites') ?? [];

    favIds.remove(mealId);
    await prefs.setStringList('favorites', favIds);

    setState(() {
      favoriteMeals.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed from favorites')),
    );
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : favoriteMeals.isEmpty
              ? Center(
                  child: Text(
                    'No favorite meals yet!',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: favoriteMeals.length,
                  itemBuilder: (context, index) {
                    final meal = favoriteMeals[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            meal.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(meal.name),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            removeFromFavorites(meal.id, index);
                          },
                        ),
                        onTap: () async {
                          final removed = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RecipeDetailScreen(mealId: meal.id),
                            ),
                          );

                          if (removed == true) {
                            setState(() {
                              favoriteMeals.removeAt(index);
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemSelected: (index) {
          if (index != _selectedBottomIndex) {
            setState(() {
              _selectedBottomIndex = index;
            });
            if (index == 0) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FavoritesScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoriesScreen()),
              );
            }
          }
        },
      ),
    );
  }
}
