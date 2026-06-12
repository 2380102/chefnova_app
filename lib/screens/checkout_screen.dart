import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_model.dart';
import '../main.dart';
import '../main_scaffold.dart';
import '../services/order_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPayment = 'cash';
  bool   _placing         = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'key': 'cash',      'label': 'Cash on Delivery',   'icon': Icons.money,                   'color': Color(0xFF4CAF50)},
    {'key': 'card',      'label': 'Credit / Debit Card', 'icon': Icons.credit_card,             'color': Color(0xFF4A90D9)},
    {'key': 'easypaisa', 'label': 'Easypaisa',           'icon': Icons.phone_android,           'color': Color(0xFF00897B)},
    {'key': 'jazzcash',  'label': 'JazzCash',            'icon': Icons.account_balance_wallet,  'color': Color(0xFFE53935)},
  ];

  Future<void> _placeOrder(CartModel cart) async {
    if (currentUser.id == 0) {
      _snack('Pehle login karein!', Colors.red);
      return;
    }
    if (cart.items.isEmpty) {
      _snack('Cart khali hai!', Colors.red);
      return;
    }
    if (currentUser.address.isEmpty) {
      _snack('Profile mein delivery address set karein pehle!', Colors.orange);
      Navigator.pushNamed(context, '/edit_profile');
      return;
    }

    setState(() => _placing = true);

    // Group items by dish → one order per dish
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in cart.items) {
      final dish = item['dish'] as String? ?? 'Unknown';
      grouped.putIfAbsent(dish, () => []).add(item);
    }

    int? lastOrderId;
    bool allSuccess = true;

    for (final entry in grouped.entries) {
      final dishItems  = entry.value;
      final recipeId   = (dishItems.first['recipe_id'] as int?) ?? 1;
      final quantity   = dishItems.length;
      final ingredients = dishItems.map((i) => i['name'] as String).join(', ');

      final result = await OrderService.placeOrder(
        recipeId:        recipeId,
        quantity:        quantity,
        totalPrice:      0.0,      // ingredients app — no price
        paymentMethod:   _selectedPayment,
        deliveryAddress: currentUser.address.isNotEmpty
            ? currentUser.address
            : 'Address not provided',
        notes: 'Ingredients: $ingredients',
      );

      if (result['success'] == true) {
        lastOrderId = result['order_id'] as int?;
      } else {
        allSuccess = false;
        _snack(result['message'] ?? 'Order place nahi hua', Colors.red);
        break;
      }
    }

    if (!mounted) return;
    setState(() => _placing = false);

    if (allSuccess) {
      cart.clearCart();
      _snack('Order place ho gaya! 🎉', Colors.green);
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
      if (lastOrderId != null) {
        Navigator.pushNamed(context, '/order_tracking');
      }
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final user = currentUser;

    // Group for display
    final Map<String, List<String>> grouped = {};
    for (var item in cart.items) {
      grouped
          .putIfAbsent(item['dish'] as String? ?? 'Items', () => [])
          .add(item['name'] as String? ?? '');
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue, foregroundColor: Colors.white,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Address missing warning
          if (user.address.isEmpty)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/edit_profile'),
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: const Row(children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 17),
                  SizedBox(width: 8),
                  Expanded(child: Text(
                    'Delivery address set nahi hai → Profile Edit karein',
                    style: TextStyle(fontSize: 12, color: Color(0xFFE65100),
                        decoration: TextDecoration.underline),
                  )),
                ]),
              ),
            ),

          // Delivery Info
          const Text('Delivery Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Column(children: [
              _infoRow(Icons.person_outline,       'Name',    user.name.isEmpty    ? '—' : user.name),
              _infoRow(Icons.email_outlined,       'Email',   user.email.isEmpty   ? '—' : user.email),
              _infoRow(Icons.phone_outlined,       'Phone',   user.phone.isEmpty   ? 'Not set' : user.phone,
                  missing: user.phone.isEmpty),
              _infoRow(Icons.location_on_outlined, 'Address', user.address.isEmpty ? 'Not set ⚠️' : user.address,
                  missing: user.address.isEmpty, isLast: true),
            ]),
          ),
          const SizedBox(height: 20),

          // Payment Method
          const Text('Payment Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._paymentMethods.map((pm) {
            final selected = _selectedPayment == pm['key'];
            return GestureDetector(
              onTap: () => setState(() => _selectedPayment = pm['key'] as String),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? kLightBlue : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: selected ? kBlue : kBorder, width: selected ? 2 : 1),
                ),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: (pm['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(pm['icon'] as IconData, color: pm['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(pm['label'] as String,
                      style: TextStyle(
                          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          color: selected ? kBlue : Colors.black87))),
                  if (selected) const Icon(Icons.check_circle, color: kBlue, size: 20),
                ]),
              ),
            );
          }),
          const SizedBox(height: 20),

          // Order Summary
          const Text('Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          if (cart.items.isEmpty)
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white,
                  borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
              child: const Center(child: Text('Cart khali hai', style: TextStyle(color: Colors.grey))),
            )
          else
            ...grouped.entries.map((entry) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Icon(Icons.restaurant, color: kBlue, size: 16),
                  const SizedBox(width: 6),
                  Text(entry.key,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kBlue)),
                ]),
                const SizedBox(height: 8),
                ...entry.value.map((ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(children: [
                    const Icon(Icons.check_circle_outline, size: 15, color: kBlue),
                    const SizedBox(width: 7),
                    Expanded(child: Text(ing, style: const TextStyle(fontSize: 13))),
                  ]),
                )),
              ]),
            )),

          // Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(color: kLightBlue, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Total Ingredients', style: TextStyle(fontWeight: FontWeight.w500)),
              Text('${cart.count}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: kBlue, fontSize: 15)),
            ]),
          ),
          const SizedBox(height: 100),
        ]),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue, foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: _placing ? null : () => _placeOrder(cart),
          child: _placing
              ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Place Order',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool missing = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(children: [
        Icon(icon, size: 17, color: kBlue),
        const SizedBox(width: 9),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(child: Text(value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                color: missing ? Colors.red : Colors.black87))),
      ]),
    );
  }
}
