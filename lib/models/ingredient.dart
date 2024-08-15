class Ingredient {
  final String name;
  final String image;

  Ingredient({required this.name, required this.image});

  factory Ingredient.fromJson(List<dynamic> json) {
    return Ingredient(
      name: json[1] as String,
      image: json[0] as String,
    );
  }
}
