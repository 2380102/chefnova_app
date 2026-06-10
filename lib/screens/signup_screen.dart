import 'package:flutter/material.dart';
import '../main.dart';
import '../main_scaffold.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameC  = TextEditingController();
  final _emailC = TextEditingController();
  final _phoneC = TextEditingController();
  final _addrC  = TextEditingController();
  final _passC  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameC.dispose(); _emailC.dispose(); _phoneC.dispose();
    _addrC.dispose(); _passC.dispose();
    super.dispose();
  }

  bool _isValidEmail(String e) =>
      RegExp(r'^[^\@\s]+@[^\@\s]+\.[^\@\s]+$').hasMatch(e);

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final result = await AuthService.signup(
      name:     _nameC.text.trim(),
      email:    _emailC.text.trim(),
      phone:    _phoneC.text.trim(),
      address:  _addrC.text.trim(),
      password: _passC.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      final u = result['user'];
      currentUser = UserModel(
        id:      u['id'] ?? 0,
        name:    u['name'] ?? '',
        email:   u['email'] ?? '',
        phone:   u['phone'] ?? '',
        address: u['address'] ?? '',
      );
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Signup failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue, foregroundColor: Colors.white,
        title: const Text('Create Account'), elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Join ChefNova!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Create your account to get started',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 20),

              _field(_nameC, 'Full Name', 'Enter your full name',
                  Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Full name is required' : null),

              _field(_emailC, 'Email', 'Enter your email',
                  Icons.email_outlined,
                  type: TextInputType.emailAddress,
                  validator: (v) {
                    if (v!.isEmpty) return 'Email is required';
                    if (!_isValidEmail(v)) return 'Please enter a valid email address';
                    return null;
                  }),

              _field(_phoneC, 'Phone Number', 'Enter your phone number',
                  Icons.phone_outlined, type: TextInputType.phone),

              _field(_addrC, 'Delivery Address',
                  'Enter your delivery address', Icons.location_on_outlined),

              _field(_passC, 'Password', 'Min 6 characters',
                  Icons.lock_outline,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    if (v!.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  }),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: _loading ? null : _signup,
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Sign Up',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ',
                      style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Login',
                        style: TextStyle(color: kBlue, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
      TextEditingController c, String label, String hint, IconData icon, {
        TextInputType type = TextInputType.text,
        bool obscure = false,
        Widget? suffix,
        String? Function(String?)? validator,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          TextFormField(
            controller: c, keyboardType: type, obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: kBlue), suffixIcon: suffix,
              filled: true, fillColor: Colors.white,
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBlue, width: 2)),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}
