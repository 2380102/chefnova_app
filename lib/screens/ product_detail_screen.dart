import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dish_model.dart';
import '../provider/cart_model.dart';
import '../main_scaffold.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // class ke ProfileView jaisa arguments receive karo
    final args = ModalRoute.of(context)!.settings.arguments
    as Map<String, dynamic>;
    final Dish dish = args['dish'];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: kBlue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: kLightBlue,
                child: Center(
                  child: Text(dish.imageEmoji,
                      style: const TextStyle(fontSize: 100)),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dish.name,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(dish.description,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _chip(Icons.timer_outlined,
                          '${dish.cookingTimeMinutes} min'),
                      const SizedBox(width: 8),
                      _chip(Icons.bar_chart, dish.difficulty),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // Ingredients
                  const Text('Ingredients',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: dish.ingredients
                        .map((ing) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 6),
                      decoration: BoxDecoration(
                        color: kLightBlue,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: kBorder),
                      ),
                      child: Text(ing,
                          style: const TextStyle(
                              fontSize: 12, color: kBlue)),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 22),

                  // Steps
                  const Text('Step-by-Step Instructions',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...dish.steps.asMap().entries.map(
                        (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                                color: kBlue,
                                shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight:
                                      FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(8),
                                border:
                                Border.all(color: kBorder),
                              ),
                              child: Text(entry.value,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      height: 1.5)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // Add to Cart — class ke CartScreen jaisa Consumer
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(14),
        color: Colors.white,
        child: Consumer<CartModel>(
          builder: (context, cart, child) {
            return ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                int added = 0;
                for (var ingredient in dish.ingredients) {
                  final exists = cart.items
                      .any((i) => i['name'] == ingredient);
                  if (!exists) {
                    cart.addItem(
                        {'name': ingredient, 'dish': dish.name});
                    added++;
                  }
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(added > 0
                        ? '${dish.name} ingredients added to cart!'
                        : 'These ingredients are already in cart!'),
                    backgroundColor: kBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Add Ingredients to Cart',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kLightBlue,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: kBlue),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 12, color: kBlue)),
        ],
      ),
    );
  }
}