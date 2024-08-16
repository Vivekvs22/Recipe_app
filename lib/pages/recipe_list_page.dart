import 'package:flutter/material.dart';
import '../services/recipe_service.dart';
import 'recipe_detail_page.dart';
import 'favorite_recipes_page.dart';

String toTitleCase(String text) {
  if (text.isEmpty) return text;
  final words = text.split(' ');
  final titleCaseWords = words.map((word) {
    if (word.length > 1) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    } else {
      return word.toUpperCase();
    }
  }).toList();
  return titleCaseWords.join(' ');
}

class RecipeListPage extends StatefulWidget {
  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  late Future<List<String>> recipeList;
  late RecipeService recipeService;
  List<String> filteredRecipes = [];
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    recipeService = RecipeService();
    recipeList = recipeService.fetchRecipeList();
    searchController.addListener(_filterRecipes);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterRecipes);
    searchController.dispose();
    super.dispose();
  }

  void _filterRecipes() async {
    final query = searchController.text.toLowerCase();
    setState(() {
      searchQuery = query;
    });
    if (query.isEmpty) {
      final allRecipes = await recipeList;
      setState(() {
        filteredRecipes = allRecipes;
      });
    } else {
      try {
        final allRecipes = await recipeService.fetchRecipeList();
        final results = allRecipes.where((recipe) => recipe.toLowerCase().contains(query)).toList();
        setState(() {
          filteredRecipes = results;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('We do not have that recipe here!!: $e')),
        );
      }
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Looks like this recipe is missing from our kitchen. Try searching for something else!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Adjust the height as needed
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blueAccent, // AppBar background color
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent, // Make the AppBar transparent
            elevation: 0, // Remove the default AppBar elevation
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.greenAccent],
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
              'Recipes',
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
            actions: [
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.white, size: 28),
                onSelected: (String result) {
                  if (result == 'Favorites') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoriteRecipesPage(),
                      ),
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Favorites',
                    child: ListTile(
                      leading: Icon(Icons.favorite, color: Colors.pinkAccent),
                      title: Text('Favorites'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search recipes...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _filterRecipes();
                  },
                )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: FutureBuilder<List<String>>(
              future: recipeList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No recipes available.'));
                }

                final recipes = searchQuery.isEmpty ? snapshot.data! : filteredRecipes;

                if (recipes.isEmpty) {
                  return Center(child: Text('No recipes found.'));
                }

                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipeName = recipes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16.0),
                        title: Text(toTitleCase(recipeName), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        onTap: () => _fetchRecipeDetails(recipeName),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
