// lib/services/recipe_service.dart
// Node.js backend se recipes ke liye API calls

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_db_model.dart';

class RecipeService {
  // Android Emulator mein 10.0.2.2 = apke PC ka localhost
  // Physical phone pe apna PC ka IP likhna hoga jaise 192.168.1.5:3000
  static const String _base = 'http://10.0.2.2:3000/api/recipes';

  // Sari recipes lao
  static Future<List<RecipeDB>> getAll() async {
    final res = await http.get(Uri.parse(_base));
    if (res.statusCode == 200) {
      final body = json.decode(res.body);
      return (body['data'] as List).map((e) => RecipeDB.fromJson(e)).toList();
    }
    throw Exception('Recipes load nahi huin: ${res.statusCode}');
  }

  // Nayi recipe banao
  static Future<bool> create(RecipeDB r) async {
    final res = await http.post(
      Uri.parse(_base),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(r.toJson()),
    );
    return res.statusCode == 201;
  }

  // Recipe update karo
  static Future<bool> update(int id, RecipeDB r) async {
    final res = await http.put(
      Uri.parse('$_base/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(r.toJson()),
    );
    return res.statusCode == 200;
  }

  // Recipe delete karo
  static Future<bool> delete(int id) async {
    final res = await http.delete(Uri.parse('$_base/$id'));
    return res.statusCode == 200;
  }
}
