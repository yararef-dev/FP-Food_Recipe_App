import 'package:flutter/material.dart';
import 'package:food_recipes/screens/category_meals_screen.dart';
import 'package:food_recipes/screens/favorites_screen.dart';
import 'package:food_recipes/screens/home_screen.dart';
import 'package:food_recipes/screens/search_screen.dart';
import 'package:food_recipes/widgets/bottom_nav_bar.dart';

import '../services/api_service.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<String> categories = [];
  bool isLoading = true;
  int _selectedBottomIndex = 3;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    try {
      final data = await ApiService.getCategories();
      if (!mounted) return;

      setState(() {
        categories = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  String getCategoryImage(String category) {
    switch (category.toLowerCase()) {
      case 'beef':
        return 'https://www.themealdb.com/images/category/beef.png';
      case 'chicken':
        return 'https://www.themealdb.com/images/category/chicken.png';
      case 'dessert':
        return 'https://www.themealdb.com/images/category/dessert.png';
      case 'seafood':
        return 'https://www.themealdb.com/images/category/seafood.png';
      case 'pasta':
        return 'https://www.themealdb.com/images/category/pasta.png';
      case 'breakfast':
        return 'https://www.themealdb.com/images/category/breakfast.png';
      case 'vegetarian':
        return 'https://www.themealdb.com/images/category/vegetarian.png';
      default:
        return 'https://www.themealdb.com/images/category/miscellaneous.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        getCategoryImage(category),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      category,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CategoryMealsScreen(category: category),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _selectedBottomIndex,
        onItemSelected: (index) {
          if (index == _selectedBottomIndex) return;

          Widget screen;
          switch (index) {
            case 0:
              screen = HomeScreen();
              break;
            case 1:
              screen = SearchScreen();
              break;
            case 2:
              screen = FavoritesScreen();
              break;
            default:
              screen = CategoriesScreen();
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}
