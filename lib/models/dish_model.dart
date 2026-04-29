class Dish {
  final String id;
  final String name;
  final String imageEmoji;
  final String description;
  final int cookingTimeMinutes;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;

  Dish({
    required this.id,
    required this.name,
    required this.imageEmoji,
    required this.description,
    required this.cookingTimeMinutes,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
  });
}