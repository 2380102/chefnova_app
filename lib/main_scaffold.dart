import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/cart_model.dart';

const Color kBlue      = Color(0xFF4A90D9);
const Color kLightBlue = Color(0xFFE8F1FC);
const Color kBorder    = Color(0xFFD6E8F8);

class MainScaffold extends StatefulWidget {
  final Widget body;
  final int currentIndex;

  const MainScaffold({
    super.key,
    required this.body,
    this.currentIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        break;
      case 1:
        Navigator.pushNamed(context, '/cart');
        break;
      case 2:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: const Text('ChefNova', style: TextStyle(fontWeight: FontWeight.w500)),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/cart'),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.shopping_cart_outlined, size: 26),
                ),
                Positioned(
                  right: 4, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${context.watch<CartModel>().count}',
                      style: const TextStyle(color: kBlue, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header - bilkul purana wala
            const DrawerHeader(
              decoration: BoxDecoration(color: kBlue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('ChefNova', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Recipe Discovery App', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),

            // === Purane menu items (waise hi) ===
            ListTile(
              leading: const Icon(Icons.home_outlined, color: kBlue),
              title: const Text('Home'),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart_outlined, color: kBlue),
              title: const Text('Cart'),
              onTap: () => Navigator.pushNamed(context, '/cart'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: kBlue),
              title: const Text('Profile'),
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),

            // === PHASE 2: Admin Panel ===
            const Divider(),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text('ADMIN PANEL', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu, color: kBlue),
              title: const Text('Recipes Manage Karein'),
              subtitle: const Text('CRUD - MySQL', style: TextStyle(fontSize: 11, color: Colors.grey)),
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/manage_recipes'); },
            ),
            ListTile(
              leading: const Icon(Icons.kitchen_outlined, color: kBlue),
              title: const Text('Ingredients Manage Karein'),
              subtitle: const Text('CRUD - MySQL', style: TextStyle(fontSize: 11, color: Colors.grey)),
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/manage_ingredients'); },
            ),

            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false),
            ),
          ],
        ),
      ),

      body: widget.body,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: kBlue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),          label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline),         label: 'Profile'),
        ],
      ),
    );
  }
}
