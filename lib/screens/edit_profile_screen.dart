import 'package:flutter/material.dart';
import '../main.dart';
import '../main_scaffold.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _addrC;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameC  = TextEditingController(text: currentUser.name);
    _phoneC = TextEditingController(text: currentUser.phone);
    _addrC  = TextEditingController(text: currentUser.address);
  }

  @override
  void dispose() {
    _nameC.dispose(); _phoneC.dispose(); _addrC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    final result = await AuthService.updateProfile(
      name:    _nameC.text.trim(),
      phone:   _phoneC.text.trim(),
      address: _addrC.text.trim(),
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (result['success'] == true) {
      final d = result['data'];
      currentUser.name    = d['name']    ?? currentUser.name;
      currentUser.phone   = d['phone']   ?? currentUser.phone;
      currentUser.address = d['address'] ?? currentUser.address;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile update ho gaya! ✅'),
          backgroundColor: kBlue, behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Profile update nahi hua'),
          backgroundColor: Colors.red, behavior: SnackBarBehavior.floating,
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
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          CircleAvatar(
            radius: 42, backgroundColor: kLightBlue,
            child: Text(
              currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 34, color: kBlue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Text(currentUser.email, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 22),

          _field(_nameC,  'Full Name',        'Enter your full name',        Icons.person_outline),
          _field(_phoneC, 'Phone Number',     'Enter your phone number',     Icons.phone_outlined,   type: TextInputType.phone),
          _field(_addrC,  'Delivery Address', 'Enter your delivery address', Icons.location_on_outlined),
          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Profile', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, String hint,
      IconData icon, {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            controller: c, keyboardType: type,
            decoration: InputDecoration(
              hintText: hint, prefixIcon: Icon(icon, color: kBlue),
              filled: true, fillColor: Colors.white,
              border:        OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kBlue, width: 2)),
            ),
          ),
        ],
      ),
    );
  }
}
