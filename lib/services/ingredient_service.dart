import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ingredient_model.dart';
import 'auth_service.dart';

class IngredientService {
  static const String _base = 'http://10.0.2.2:3000/api/ingredients';

  static Future<List<Ingredient>> getAll() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse(_base), headers: headers);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      return (body['data'] as List).map((e) => Ingredient.fromJson(e)).toList();
    }
    throw Exception('Ingredients load nahi hue: ${res.statusCode}');
  }

  static Future<List<Ingredient>> getByRecipe(int recipeId) async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse('$_base/recipe/$recipeId'), headers: headers);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      return (body['data'] as List).map((e) => Ingredient.fromJson(e)).toList();
    }
    throw Exception('Ingredients nahi mile');
  }

  static Future<bool> create(Ingredient ing) async {
    final headers = await AuthService.authHeaders();
    final res = await http.post(
      Uri.parse(_base), headers: headers,
      body: json.encode(ing.toJson()),
    );
    return res.statusCode == 201;
  }

  static Future<bool> update(int id, Ingredient ing) async {
    final headers = await AuthService.authHeaders();
    final res = await http.put(
      Uri.parse('$_base/$id'), headers: headers,
      body: json.encode(ing.toJson()),
    );
    return res.statusCode == 200;
  }

  static Future<bool> delete(int id) async {
    final headers = await AuthService.authHeaders();
    final res = await http.delete(Uri.parse('$_base/$id'), headers: headers);
    return res.statusCode == 200;
  }
}
