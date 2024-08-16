import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;

  RecipeDetailPage({required this.recipe});

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool isFavorite = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initializeFavoriteStatus();
  }

  Future<void> _initializeFavoriteStatus() async {
    prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites') ?? [];
    setState(() {
      isFavorite = favorites.contains(widget.recipe.name.toLowerCase());
    });
  }

  Future<void> _toggleFavorite() async {
    final favorites = prefs.getStringList('favorites') ?? [];
    if (isFavorite) {
      favorites.remove(widget.recipe.name.toLowerCase());
    } else {
      favorites.add(widget.recipe.name.toLowerCase());
    }
    await prefs.setStringList('favorites', favorites);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.pink),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.recipe.image,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => Image.asset('lib/assets/default_image.png'),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.recipe.description.contains('Description not found')
                        ? 'Looks like the chef forgot to add a description for this recipe! How about trying a different dish or checking back soon for more details.'
                        : widget.recipe.description,
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            widget.recipe.ingredients.isEmpty
                ? Text('No ingredients available.', style: TextStyle(fontSize: 16))
                : Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: ListView.separated(
                itemCount: widget.recipe.ingredients.length,
                separatorBuilder: (context, index) => Divider(),
                itemBuilder: (context, index) {
                  final ingredient = widget.recipe.ingredients[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                    leading: CachedNetworkImage(
                      imageUrl: ingredient.image.isNotEmpty ? ingredient.image : 'lib/assets/default_ingredient_placeholder.png',
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Image.asset('lib/assets/default_ingredient_image.png'),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      toTitleCase(ingredient.name.isNotEmpty ? ingredient.name : 'Ingredient '),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
