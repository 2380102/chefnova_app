import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_model.dart';
import '../main_scaffold.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // class ke CartScreen jaisa Consumer
    return Consumer<CartModel>(
      builder: (context, cart, child) {
        return MainScaffold(
          currentIndex: 1,
          body: cart.items.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('🛒', style: TextStyle(fontSize: 60)),
                SizedBox(height: 14),
                Text('Your cart is empty!',
                    style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 5),
                Text('Select a dish to add ingredients',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey)),
              ],
            ),
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Container(
                      margin:
                      const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(10),
                        border: Border.all(color: kBorder),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: kLightBlue,
                            borderRadius:
                            BorderRadius.circular(8),
                          ),
                          child: const Icon(
                              Icons.kitchen_outlined,
                              color: kBlue),
                        ),
                        title: Text(item['name'],
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(
                            'For: ${item['dish']}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey)),
                        // class ke CartScreen jaisa removeItem
                        trailing: IconButton(
                          icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () =>
                              cart.removeItem(item['name']),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Summary + Checkout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      top: BorderSide(color: kBorder)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Items:',
                            style: TextStyle(fontSize: 15)),
                        Text('${cart.count}',
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: kBlue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: () => Navigator.pushNamed(
                            context, '/checkout'),
                        child: const Text(
                            'Proceed to Checkout',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}