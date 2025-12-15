import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;
  RecipeDetailScreen({required this.mealId});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Meal? meal;
  bool isFavorite = false;
  bool isLoading = true;

  void fetchMeal() async {
    try {
      final data = await ApiService.getMealDetail(widget.mealId);
      if (data.isNotEmpty) {
        setState(() {
          meal = Meal.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          meal = Meal(
            id: '',
            name: 'Meal not found',
            category: '',
            area: '',
            instructions: 'No instructions available.',
            image: '',
            ingredients: [],
          );
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        meal = Meal(
          id: '',
          name: 'Error loading meal',
          category: '',
          area: '',
          instructions: 'Could not fetch meal details.',
          image: '',
          ingredients: [],
        );
        isLoading = false;
      });
      print("Error fetching meal: $e");
    }
  }

  void loadFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites') ?? [];
    setState(() => isFavorite = favs.contains(widget.mealId));
  }

  void toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favs = prefs.getStringList('favorites') ?? [];

    if (isFavorite) {
      favs.remove(widget.mealId);
      await prefs.setStringList('favorites', favs);

      setState(() => isFavorite = false);

      Navigator.pop(context, true);
    } else {
      favs.add(widget.mealId);
      await prefs.setStringList('favorites', favs);

      setState(() => isFavorite = true);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMeal();
    loadFavorite();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading)
      return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: Text(meal!.name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            onPressed: toggleFavorite,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            meal!.image.isNotEmpty
                ? Image.network(meal!.image)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(child: Text('No Image')),
                  ),
            SizedBox(height: 12),
            Text(
              meal!.category.isNotEmpty || meal!.area.isNotEmpty
                  ? '${meal!.category} | ${meal!.area}'
                  : '',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            if (meal!.ingredients.isNotEmpty) ...[
              Text('Ingredients',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: meal!.ingredients.map((i) {
                  final ingredient = i['ingredient'] ?? '';
                  final measure = i['measure'] ?? '';
                  final imgUrl =
                      'https://www.themealdb.com/images/ingredients/$ingredient-Small.png';
                  return Tooltip(
                    message: '$ingredient - $measure',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.network(
                          imgUrl,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.fastfood, size: 40);
                          },
                        ),
                        SizedBox(height: 2),
                        SizedBox(
                          width: 60,
                          child: Text(
                            ingredient,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 12),
            ],
            Text('Instructions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(meal!.instructions),
          ],
        ),
      ),
    );
  }
}
