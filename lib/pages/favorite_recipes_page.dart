import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_page.dart';


class FavoriteRecipesPage extends StatefulWidget {
  @override
  _FavoriteRecipesPageState createState() => _FavoriteRecipesPageState();
}

class _FavoriteRecipesPageState extends State<FavoriteRecipesPage> {
  late Future<List<String>> favoriteRecipes;
  late RecipeService recipeService;

  @override
  void initState() {
    super.initState();
    recipeService = RecipeService();
    favoriteRecipes = _getFavoriteRecipes();
  }

  Future<List<String>> _getFavoriteRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites');
    if (favorites == null) {
      print('No favorites found in SharedPreferences');
      return [];
    }
    return favorites;
  }

  Future<void> _fetchRecipeDetails(String recipeName) async {
    final normalizedRecipeName = recipeName.toLowerCase();
    try {
      final recipe = await recipeService.fetchRecipeDetails(normalizedRecipeName);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeDetailPage(recipe: recipe),
        ),
      );
    } catch (e) {
      print('Error fetching recipe details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load recipe details: $e')),
      );
    }
  }

  Future<void> _removeFavorite(String recipeName) async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favorites = prefs.getStringList('favorites');
    if (favorites == null) return;

    favorites.remove(recipeName.toLowerCase());
    await prefs.setStringList('favorites', favorites);

    setState(() {
      favoriteRecipes = Future.value(favorites);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed $recipeName from favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.pinkAccent,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.pink],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            title: Text(
              'Favorite Recipes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.4),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: favoriteRecipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No favorites yet.'));
          }

          final recipes = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipeName = recipes[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  title: Text(
                    recipeName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeFavorite(recipeName),
                  ),
                  onTap: () => _fetchRecipeDetails(recipeName),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
