import 'package:flutter/material.dart';
import 'package:food_recipes/screens/categories_screen.dart';
import 'package:food_recipes/screens/search_screen.dart';

import '../models/meal.dart';
import '../services/api_service.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/meal_card.dart';
import 'favorites_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Meal> meals = [];
  List<Meal> filteredMeals = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  int _selectedBottomIndex = 0; // Index for bottom nav

  @override
  void initState() {
    super.initState();
    fetchMeals();
  }

  void fetchMeals() async {
    setState(() => isLoading = true);
    final data = await ApiService.getAllMeals();
    setState(() {
      meals = data;
      filteredMeals = meals;
      isLoading = false;
    });
  }

  void filterMeals(String query) {
    final suggestions = meals.where((meal) {
      final nameLower = meal.name.toLowerCase();
      final ingredientsLower =
          meal.ingredients.map((e) => e['ingredient']!.toLowerCase()).join(' ');
      final searchLower = query.toLowerCase();
      return nameLower.contains(searchLower) ||
          ingredientsLower.contains(searchLower);
    }).toList();

    setState(() {
      filteredMeals = suggestions;
    });
  }

  Widget buildBody() {
    if (_selectedBottomIndex == 0) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or ingredient...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: filterMeals,
            ),
          ),
          SizedBox(height: 8),

          if (searchController.text.isEmpty)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: meals.length > 10 ? 10 : meals.length,
                itemBuilder: (context, index) {
                  final meal = meals[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(mealId: meal.id),
                        ),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              meal.image,
                              height: 100,
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            meal.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          SizedBox(height: 8),

          // Meals List
          Expanded(
            child: filteredMeals.isEmpty
                ? Center(child: Text('No meals found'))
                : ListView.builder(
                    itemCount: filteredMeals.length,
                    itemBuilder: (context, index) {
                      return MealCard(
                        meal: filteredMeals[index],
                      );
                    },
                  ),
          ),
        ],
      );
    } else if (_selectedBottomIndex == 1) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: filterMeals,
            ),
            SizedBox(height: 8),
            Expanded(
              child: filteredMeals.isEmpty
                  ? Center(child: Text('No meals found'))
                  : ListView.builder(
                      itemCount: filteredMeals.length,
                      itemBuilder: (context, index) {
                        return MealCard(meal: filteredMeals[index]);
                      },
                    ),
            ),
          ],
        ),
      );
    } else if (_selectedBottomIndex == 2) {
      return FavoritesScreen();
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Recipes'),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, color: Colors.white, size: 42),
                  SizedBox(height: 10),
                  Text('Food Recipes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  Text('Discover delicious meals',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.category),
              title: Text('Categories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CategoriesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.red),
              title: Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FavoritesScreen()),
                );
              },
            ),
            Divider(),
          ],
        ),
      ),
      body:
          isLoading ? Center(child: CircularProgressIndicator()) : buildBody(),
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
