import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class OrderService {
  static const String _base = 'http://10.0.2.2:3000/api/orders';

  // Order place karo
  static Future<Map<String, dynamic>> placeOrder({
    required int    recipeId,
    required int    quantity,
    required double totalPrice,
    required String paymentMethod,
    required String deliveryAddress,
    String notes = '',
  }) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.post(
        Uri.parse(_base),
        headers: headers,
        body: json.encode({
          'recipe_id':       recipeId,
          'quantity':        quantity,
          'total_price':     totalPrice,
          'payment_method':  paymentMethod,
          'delivery_address': deliveryAddress,
          'notes':           notes,
        }),
      );
      return json.decode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Order place nahi hua. Backend check karein.'};
    }
  }

  // Mere sare orders
  static Future<Map<String, dynamic>> getMyOrders() async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse(_base), headers: headers);
      return json.decode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Orders load nahi hue.'};
    }
  }

  // Single order track
  static Future<Map<String, dynamic>> getOrderById(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.get(Uri.parse('$_base/$id'), headers: headers);
      return json.decode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Order nahi mila.'};
    }
  }

  // Cancel order
  static Future<Map<String, dynamic>> cancelOrder(int id) async {
    try {
      final headers = await AuthService.authHeaders();
      final res = await http.put(Uri.parse('$_base/$id/cancel'), headers: headers);
      return json.decode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Order cancel nahi hua.'};
    }
  }
}
