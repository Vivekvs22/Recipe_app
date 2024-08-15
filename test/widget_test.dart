import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_app/main.dart';
import 'package:recipe_app/models/recipe.dart';
import 'package:recipe_app/pages/recipe_detail_page.dart';
import 'package:recipe_app/pages/recipe_list_page.dart';
import 'package:recipe_app/pages/favorite_recipes_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Mock class for SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}

// Mock class for HTTP client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  testWidgets('Recipe List Page displays recipes', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the Recipe List Page is shown.
    expect(find.byType(RecipeListPage), findsOneWidget);

    // Simulate loading of recipes (use mock service or specific data if needed).
    // Example: expect(find.text('Recipe Name'), findsOneWidget);  // Replace with real recipe names in your test.
  });

  testWidgets('Recipe Detail Page displays recipe details', (WidgetTester tester) async {
    // Create a sample recipe.
    final recipe = Recipe(
      name: 'Masala Dosa',
      image: 'https://example.com/masala_dosa.jpg',
      description: 'A spicy Indian crepe.',
      ingredients: [
        Ingredient(name: 'Dosa', image: 'https://example.com/dosa.jpg'),
        Ingredient(name: 'Masala', image: 'https://example.com/masala.jpg'),
      ],
    );

    // Build our app with the RecipeDetailPage.
    await tester.pumpWidget(MaterialApp(
      home: RecipeDetailPage(recipe: recipe),
    ));

    // Verify the recipe details.
    expect(find.text(recipe.name), findsOneWidget);
    expect(find.text(recipe.description), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(3)); // One for recipe image and one for each ingredient.
  });

  testWidgets('Favorite Recipes Page displays favorite recipes', (WidgetTester tester) async {
    // Mock SharedPreferences
    final mockPrefs = MockSharedPreferences();
    when(mockPrefs.getStringList('favorites')).thenReturn(['Masala Dosa']);

    // Build the app with FavoriteRecipesPage.
    await tester.pumpWidget(MaterialApp(
      home: FavoriteRecipesPage(),
    ));

    // Verify that the favorite recipe is displayed.
    expect(find.text('Masala Dosa'), findsOneWidget);
  });

  testWidgets('Favorite button toggles state', (WidgetTester tester) async {
    // Mock SharedPreferences
    final mockPrefs = MockSharedPreferences();
    when(mockPrefs.getStringList('favorites')).thenReturn([]);

    // Build the app with RecipeListPage.
    await tester.pumpWidget(MaterialApp(
      home: RecipeListPage(),
    ));

    // Simulate tapping the favorite button.
    final favoriteButtonFinder = find.byIcon(Icons.favorite_border);
    expect(favoriteButtonFinder, findsOneWidget);

    await tester.tap(favoriteButtonFinder);
    await tester.pump();

    // After tapping, the icon should change to filled.
    expect(find.byIcon(Icons.favorite), findsOneWidget);
  });
}
