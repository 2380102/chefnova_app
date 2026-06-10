import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _base = 'http://10.0.2.2:3000/api/auth';
  static const String _tokenKey = 'auth_token';
  static const String _userKey  = 'auth_user';

  // Token save karo
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Token lao
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Token delete karo (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // User save karo
  static Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(userData));
  }

  // Saved user lao
  static Future<UserModel?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_userKey);
    if (str == null) return null;
    final data = json.decode(str);
    return UserModel(
      id:       data['id'] ?? 0,
      name:     data['name'] ?? '',
      email:    data['email'] ?? '',
      phone:    data['phone'] ?? '',
      address:  data['address'] ?? '',
    );
  }

  // SIGNUP
  static Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'password': password,
        }),
      );
      final body = json.decode(res.body);
      if (res.statusCode == 201 && body['success'] == true) {
        await saveToken(body['token']);
        await saveUser(body['user']);
      }
      return body;
    } catch (e) {
      return {'success': false, 'message': 'Server se connect nahi ho saka. Backend chala raha hai?'};
    }
  }

  // LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      final body = json.decode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        await saveToken(body['token']);
        await saveUser(body['user']);
      }
      return body;
    } catch (e) {
      return {'success': false, 'message': 'Server se connect nahi ho saka. Backend chala raha hai?'};
    }
  }

  // PROFILE UPDATE
  static Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      final token = await getToken();
      final res = await http.put(
        Uri.parse('$_base/profile/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': name, 'phone': phone, 'address': address}),
      );
      final body = json.decode(res.body);
      if (body['success'] == true) {
        await saveUser(body['data']);
      }
      return body;
    } catch (e) {
      return {'success': false, 'message': 'Profile update nahi hua'};
    }
  }

  // Auth header
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }
}
