import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'provider/cart_model.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/ product_detail_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/signup_screen.dart';
import 'models/user_model.dart';

// Global current user — class ke pattern jaisa
UserModel currentUser = UserModel();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: const ChefNovaApp(),
    ),
  );
}

class ChefNovaApp extends StatelessWidget {
  const ChefNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChefNova',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
        ),
        useMaterial3: true,
      ),
      // Named routes — class ke main.dart jaisa
      initialRoute: '/login',
      routes: {
        '/login':        (context) => const LoginScreen(),
        '/signup':       (context) => const SignupScreen(),
        '/':             (context) => const HomeScreen(),
        '/detail':       (context) => const ProductDetailScreen(),
        '/cart':         (context) => const CartScreen(),
        '/checkout':     (context) => const CheckoutScreen(),
        '/profile':      (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      },
    );
  }
}