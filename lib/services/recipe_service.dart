import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_db_model.dart';
import 'auth_service.dart';

class RecipeService {
  static const String _base = 'http://10.0.2.2:3000/api/recipes';

  static Future<List<RecipeDB>> getAll() async {
    final headers = await AuthService.authHeaders();
    final res = await http.get(Uri.parse(_base), headers: headers);
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      return (body['data'] as List).map((e) => RecipeDB.fromJson(e)).toList();
    }
    throw Exception('Recipes load nahi huin: ${res.statusCode}');
  }

  static Future<bool> create(RecipeDB r) async {
    final headers = await AuthService.authHeaders();
    final res = await http.post(
      Uri.parse(_base), headers: headers,
      body: json.encode(r.toJson()),
    );
    return res.statusCode == 201;
  }

  static Future<bool> update(int id, RecipeDB r) async {
    final headers = await AuthService.authHeaders();
    final res = await http.put(
      Uri.parse('$_base/$id'), headers: headers,
      body: json.encode(r.toJson()),
    );
    return res.statusCode == 200;
  }

  static Future<bool> delete(int id) async {
    final headers = await AuthService.authHeaders();
    final res = await http.delete(Uri.parse('$_base/$id'), headers: headers);
    return res.statusCode == 200;
  }
}
