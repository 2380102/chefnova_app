

class Ingredient {
  final int?   id;
  final int    recipeId;
  final String name;
  final String quantity;
  final String unit;
  final String? recipeName;

  Ingredient({
    this.id,
    required this.recipeId,
    required this.name,
    required this.quantity,
    required this.unit,
    this.recipeName,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      id:          json['id'],
      recipeId:    json['recipe_id'],
      name:        json['name']        ?? '',
      quantity:    json['quantity']    ?? '',
      unit:        json['unit']        ?? '',
      recipeName:  json['recipe_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'recipe_id': recipeId,
    'name':      name,
    'quantity':  quantity,
    'unit':      unit,
  };
}
