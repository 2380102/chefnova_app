import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_model.dart';
import '../main.dart';
import '../main_scaffold.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartModel>();
    final user = currentUser;

    final grouped = <String, List<String>>{};
    for (var item in cart.items) {
      grouped.putIfAbsent(item['dish'], () => []).add(item['name']);
    }

    final bool infoMissing =
        user.phone.isEmpty || user.address.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: const Text('Checkout',
            style: TextStyle(fontWeight: FontWeight.w500)),
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
                  border: Border.all(
                      color: const Color(0xFFFFB74D)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFE65100), size: 17),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please complete your profile before checkout',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFE65100)),
                      ),
                    ),
                  ],
                ),
              ),

            // Delivery Info
            const Text('Delivery Information',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  _infoRow(Icons.person_outline, 'Name',
                      user.name.isEmpty ? '—' : user.name),
                  _infoRow(Icons.email_outlined, 'Email',
                      user.email.isEmpty ? '—' : user.email),
                  _infoRow(Icons.phone_outlined, 'Phone',
                      user.phone.isEmpty ? 'Not set' : user.phone,
                      missing: user.phone.isEmpty),
                  _infoRow(
                    Icons.location_on_outlined,
                    'Address',
                    user.address.isEmpty
                        ? 'Not set'
                        : user.address,
                    missing: user.address.isEmpty,
                    isLast: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order Summary
            const Text('Order Summary',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
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
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: kBlue)),
                    const SizedBox(height: 8),
                    ...entry.value.map(
                          (ing) => Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline,
                                size: 15, color: kBlue),
                            const SizedBox(width: 7),
                            Text(ing,
                                style:
                                const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: kLightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Ingredients',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  Text('${cart.count}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kBlue,
                          fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 90),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        color: Colors.white,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          onPressed: () {
            context.read<CartModel>().clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                Text('Order placed successfully! 🎉'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
                context, '/', (route) => false);
          },
          child: const Text('Place Order',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value,
      {bool missing = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
            bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: kBlue),
          const SizedBox(width: 9),
          Text('$label: ',
              style: const TextStyle(
                  color: Colors.grey, fontSize: 13)),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: missing ? Colors.red : Colors.black87)),
          ),
        ],
      ),
    );
  }
}