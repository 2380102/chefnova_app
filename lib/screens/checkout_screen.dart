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
    {'key': 'cash',       'label': 'Cash on Delivery', 'icon': Icons.money,          'color': Color(0xFF4CAF50)},
    {'key': 'card',       'label': 'Credit / Debit Card','icon': Icons.credit_card,   'color': Color(0xFF4A90D9)},
    {'key': 'easypaisa',  'label': 'Easypaisa',         'icon': Icons.phone_android,  'color': Color(0xFF00897B)},
    {'key': 'jazzcash',   'label': 'JazzCash',           'icon': Icons.account_balance_wallet, 'color': Color(0xFFE53935)},
  ];

  Future<void> _placeOrder(CartModel cart) async {
    if (currentUser.id == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pehle login karein!'), backgroundColor: Colors.red),
      );
      return;
    }
    if (currentUser.address.isEmpty || currentUser.phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile mein address aur phone number bharo pehle!'),
          backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart khali hai!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _placing = true);

    // Group by dish → place one order per dish (using recipe name as key)
    // For simplicity: place single order with first dish's recipe_id
    // In real app you'd get recipe_id from cart item
    final dishName = cart.items.isNotEmpty ? cart.items.first['dish'] as String : 'Order';

    final result = await OrderService.placeOrder(
      recipeId:        cart.items.isNotEmpty ? (cart.items.first['recipe_id'] ?? 1) as int : 1,
      quantity:        cart.count,
      totalPrice:      cart.count * 0.0, // free ingredients / adjust as needed
      paymentMethod:   _selectedPayment,
      deliveryAddress: currentUser.address,
      notes:           'Items: ${cart.items.map((i) => i['name']).join(', ')}',
    );

    if (!mounted) return;
    setState(() => _placing = false);

    if (result['success'] == true) {
      cart.clearCart();
      final orderId = result['order_id'];
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order place ho gaya! 🎉'),
          backgroundColor: Colors.green, behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      // Navigate to tracking
      if (orderId != null) {
        Navigator.pushNamed(context, '/order_tracking', arguments: orderId);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Order place nahi hua'),
          backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final user = currentUser;

    final grouped = <String, List<String>>{};
    for (var item in cart.items) {
      grouped.putIfAbsent(item['dish'] as String, () => []).add(item['name'] as String);
    }

    final bool infoMissing = user.phone.isEmpty || user.address.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue, foregroundColor: Colors.white,
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning
            if (infoMissing)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Row(children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE65100), size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/edit_profile'),
                      child: const Text(
                        'Phone aur address complete karein → Profile Edit karein',
                        style: TextStyle(fontSize: 12, color: Color(0xFFE65100),
                            decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                ]),
              ),

            // Delivery Info
            const Text('Delivery Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Column(children: [
                _infoRow(Icons.person_outline, 'Name',     user.name.isEmpty  ? '—' : user.name),
                _infoRow(Icons.email_outlined, 'Email',    user.email.isEmpty ? '—' : user.email),
                _infoRow(Icons.phone_outlined, 'Phone',    user.phone.isEmpty ? 'Not set' : user.phone,   missing: user.phone.isEmpty),
                _infoRow(Icons.location_on_outlined, 'Address', user.address.isEmpty ? 'Not set' : user.address,
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
                    if (selected)
                      const Icon(Icons.check_circle, color: kBlue, size: 20),
                  ]),
                ),
              );
            }),
            const SizedBox(height: 20),

            // Order Summary
            const Text('Order Summary',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...grouped.entries.map(
                  (entry) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kBlue)),
                    const SizedBox(height: 8),
                    ...entry.value.map((ing) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(children: [
                        const Icon(Icons.check_circle_outline, size: 15, color: kBlue),
                        const SizedBox(width: 7),
                        Text(ing, style: const TextStyle(fontSize: 13)),
                      ]),
                    )),
                  ],
                ),
              ),
            ),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: kLightBlue, borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Ingredients', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('${cart.count}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: kBlue, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
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
              : const Text('Place Order', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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
