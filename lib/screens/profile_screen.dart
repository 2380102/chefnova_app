import 'package:flutter/material.dart';
import '../main.dart';
import '../main_scaffold.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    return MainScaffold(
      currentIndex: 2,
      body: SingleChildScrollView(
        child: Column(children: [
          // Header
          Container(
            width: double.infinity, color: kBlue,
            padding: const EdgeInsets.symmetric(vertical: 26),
            child: Column(children: [
              CircleAvatar(
                radius: 42, backgroundColor: Colors.white,
                child: Text(initials,
                    style: const TextStyle(fontSize: 34, color: kBlue, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Text(user.name.isEmpty ? 'Your Name' : user.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              Text(user.email.isEmpty ? 'your@email.com' : user.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              _card(Icons.person_outline,      'Full Name',        user.name.isEmpty    ? 'Not set' : user.name),
              _card(Icons.email_outlined,      'Email',            user.email.isEmpty   ? 'Not set' : user.email),
              _card(Icons.phone_outlined,      'Phone Number',     user.phone.isEmpty   ? 'Not set' : user.phone),
              _card(Icons.location_on_outlined,'Delivery Address', user.address.isEmpty ? 'Not set' : user.address),
              const SizedBox(height: 14),

              // Edit Profile
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/edit_profile')
                      .then((_) => setState(() {})),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 10),

              // My Orders
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kBlue,
                    side: const BorderSide(color: kBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/order_tracking'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('My Orders', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(height: 10),

              // Logout
              SizedBox(
                width: double.infinity, height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    await AuthService.clearToken();
                    currentUser = currentUser..name = ''
                      ..email = ''..phone = ''..address = ''..id = 0;
                    if (!mounted) return;
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout', style: TextStyle(fontSize: 14)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _card(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: kLightBlue, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: kBlue, size: 19),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,  style: const TextStyle(fontSize: 11, color: Colors.grey)),
          Text(value,  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }
}
