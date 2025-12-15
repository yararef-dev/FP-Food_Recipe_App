import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

class ApiService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Meal>> getAllMeals() async {
    List<Meal> allMeals = [];

    final letters = 'abcdefghijklmnopqrstuvwxyz'.split('');

    List<Future<List<Meal>>> requests = letters.map((letter) async {
      final url = Uri.parse('$baseUrl/search.php?f=$letter');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List? mealsJson = data['meals'];
        if (mealsJson != null) {
          return mealsJson.map((json) => Meal.fromJson(json)).toList();
        }
      }
      return <Meal>[];
    }).toList();

    final results = await Future.wait(requests);

    for (var list in results) {
      allMeals.addAll(list);
    }

    return allMeals;
  }

  static Future<Map<String, dynamic>> getMealDetail(String id) async {
    final url = Uri.parse('$baseUrl/lookup.php?i=$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['meals'][0] ?? {};
    } else {
      return {};
    }
  }

  static Future<List<String>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories.php');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List categories = data['categories'];
      return categories.map((c) => c['strCategory'] as String).toList();
    } else {
      return [];
    }
  }

  static Future<List<Meal>> getMealsByCategory(String category) async {
    final url = Uri.parse('$baseUrl/filter.php?c=$category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List mealsJson = data['meals'] ?? [];

      return mealsJson.map((json) => Meal.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
