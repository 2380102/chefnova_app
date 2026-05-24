
class RecipeDB {
  final int?   id;
  final String name;
  final String category;
  final String description;
  final int    cookTime;
  final String difficulty;
  final String emoji;

  RecipeDB({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.cookTime,
    required this.difficulty,
    required this.emoji,
  });


  factory RecipeDB.fromJson(Map<String, dynamic> json) {
    return RecipeDB(
      id:          json['id'],
      name:        json['name']        ?? '',
      category:    json['category']    ?? '',
      description: json['description'] ?? '',
      cookTime:    json['cook_time']   ?? 0,
      difficulty:  json['difficulty']  ?? 'Easy',
      emoji:       json['emoji']       ?? '🍽️',
    );
  }


  Map<String, dynamic> toJson() => {
    'name':        name,
    'category':    category,
    'description': description,
    'cook_time':   cookTime,
    'difficulty':  difficulty,
    'emoji':       emoji,
  };
}
