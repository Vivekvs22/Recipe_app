
class Recipe {
  final String name;
  final String image;
  final String description;
  final List<Ingredient> ingredients;

  Recipe({
    required this.name,
    required this.image,
    required this.description,
    required this.ingredients,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredientsList = (json['keyIngredients'] as List<dynamic>).map((item) {
      return Ingredient(
        name: item[1] as String,
        image: item[0] as String,
      );
    }).toList();

    return Recipe(
      name: json['foodName'] as String,
      image: json['foodImage'] as String,
      description: json['foodDescription'] as String,
      ingredients: ingredientsList,
    );
  }
}

class Ingredient {
  final String name;
  final String image;

  Ingredient({
    required this.name,
    required this.image,
  });
}
