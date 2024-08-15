import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeService {
  final String baseUrl = 'https://ayur-analytics-6mthurpbxq-el.a.run.app';

  Future<List<String>> fetchRecipeList() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/all'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<String> recipes = List<String>.from(data['recipesList']);
        return recipes;
      } else {
        return Future.error('It seems we couldn’t fetch the recipe list. Please try again later.');
      }
    } catch (e) {
      return Future.error('Oops! Something went wrong while fetching the recipe list.\n Please Check the internet connection!!');
    }
  }

  Future<Recipe> fetchRecipeDetails(String recipeName) async {
    final encodedRecipeName = Uri.encodeComponent(recipeName);
    try {
      final response = await http.get(Uri.parse('$baseUrl/get/$encodedRecipeName'));

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);


          final foodImage = data['foodImage'] ?? 'lib/assets/default_image.png';
          final foodName = data['foodName'] ?? 'Food 1';
          final foodDescription = data['foodDescription'] ?? 'hey food description went away!!';
          final keyIngredients = (data['keyIngredients'] as List<dynamic>?)
              ?.map((item) {
            final ingredientData = item as List<dynamic>;
            return Ingredient(
              name: ingredientData[1] ?? 'Unknown',
              image: ingredientData[0] ?? 'lib/assets/default_ingredient_image.png',
            );
          })
              .toList() ?? [];

          return Recipe(
            name: foodName,
            image: foodImage,
            description: foodDescription,
            ingredients: keyIngredients,
          );
        } catch (e) {
          throw Exception('Oops! We couldn’t fetch the details for the recipe. Please try again later.');
        }
      } else {
        throw Exception('Sorry, but we can’t retrieve the recipe details right now. Please try again later.');
      }
    } catch (e) {
      throw Exception('Oops! Something went wrong while fetching the recipe details.');
    }
  }
}
