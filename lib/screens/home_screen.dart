import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/dish_model.dart';
import '../main_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  List<Dish> get _filteredDishes {
    if (_searchQuery.isEmpty) return sampleDishes;
    return sampleDishes
        .where((d) => d.name
        .toLowerCase()
        .contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      currentIndex: 0,
      body: Column(
        children: [
          // Search bar
          Container(
            color: kBlue,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search for any dish...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon:
                const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Dish list
          Expanded(
            child: _filteredDishes.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('😔',
                      style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text('No dish found',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey)),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: _filteredDishes.length,
              itemBuilder: (context, index) {
                final dish = _filteredDishes[index];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/detail',
                    arguments: {'dish': dish},
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 85,
                          height: 85,
                          decoration: const BoxDecoration(
                            color: kLightBlue,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(dish.imageEmoji,
                                style: const TextStyle(
                                    fontSize: 38)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(11),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(dish.name,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight:
                                        FontWeight.w600)),
                                const SizedBox(height: 3),
                                Text(dish.description,
                                    style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12),
                                    maxLines: 2,
                                    overflow:
                                    TextOverflow.ellipsis),
                                const SizedBox(height: 7),
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.timer_outlined,
                                        size: 13,
                                        color: kBlue),
                                    const SizedBox(width: 3),
                                    Text(
                                        '${dish.cookingTimeMinutes} min',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets
                                          .symmetric(
                                          horizontal: 7,
                                          vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kLightBlue,
                                        borderRadius:
                                        BorderRadius
                                            .circular(6),
                                      ),
                                      child: Text(
                                          dish.difficulty,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: kBlue)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(Icons.arrow_forward_ios,
                              size: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}