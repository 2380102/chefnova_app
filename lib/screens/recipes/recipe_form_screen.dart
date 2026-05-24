// lib/screens/recipes/recipe_form_screen.dart
// Add aur Edit Recipe form

import 'package:flutter/material.dart';
import '../../models/recipe_db_model.dart';
import '../../services/recipe_service.dart';

const Color kBlue   = Color(0xFF4A90D9);
const Color kBorder = Color(0xFFD6E8F8);

class RecipeFormScreen extends StatefulWidget {
  final RecipeDB? existing; // null = add, value = edit
  const RecipeFormScreen({super.key, this.existing});
  @override
  State<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends State<RecipeFormScreen> {
  final _key          = GlobalKey<FormState>();
  late TextEditingController _name, _desc, _time, _emoji;
  String _cat  = 'Main Course';
  String _diff = 'Easy';
  bool   _busy = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name  = TextEditingController(text: e?.name        ?? '');
    _desc  = TextEditingController(text: e?.description ?? '');
    _time  = TextEditingController(text: e?.cookTime.toString() ?? '');
    _emoji = TextEditingController(text: e?.emoji       ?? '🍽️');
    if (e != null) { _cat = e.category; _diff = e.difficulty; }
  }

  @override
  void dispose() { _name.dispose(); _desc.dispose(); _time.dispose(); _emoji.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _busy = true);

    final r = RecipeDB(
      name: _name.text.trim(), category: _cat,
      description: _desc.text.trim(), cookTime: int.parse(_time.text.trim()),
      difficulty: _diff, emoji: _emoji.text.trim().isEmpty ? '🍽️' : _emoji.text.trim(),
    );

    final ok = _editing
        ? await RecipeService.update(widget.existing!.id!, r)
        : await RecipeService.create(r);

    setState(() => _busy = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? (_editing ? '✅ Recipe update ho gayi!' : '✅ Recipe add ho gayi!') : '❌ Error! Dobara try karein.'),
      backgroundColor: ok ? Colors.green : Colors.red,
    ));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue, foregroundColor: Colors.white,
        title: Text(_editing ? 'Recipe Edit Karein' : 'Nayi Recipe Add Karein',
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: [
              _box(_field(_emoji, 'Emoji (jaise 🍛)', Icons.emoji_food_beverage_outlined)),
              const SizedBox(height: 10),
              _box(_field(_name, 'Recipe ka Naam', Icons.restaurant_menu,
                  v: (s) => s!.isEmpty ? 'Naam zaroor likhein' : null)),
              const SizedBox(height: 10),
              _box(DropdownButtonFormField<String>(
                value: _cat,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined, color: kBlue), border: InputBorder.none),
                items: ['Breakfast', 'Main Course', 'Fast Food', 'Dessert', 'Drinks']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _cat = v!),
              )),
              const SizedBox(height: 10),
              _box(TextFormField(
                controller: _desc, maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.notes, color: kBlue), border: InputBorder.none, alignLabelWithHint: true),
              )),
              const SizedBox(height: 10),
              _box(_field(_time, 'Cooking Time (minutes)', Icons.timer_outlined,
                  type: TextInputType.number,
                  v: (s) { if (s!.isEmpty) return 'Time likhein'; if (int.tryParse(s) == null) return 'Sirf number likhein'; return null; })),
              const SizedBox(height: 10),
              _box(DropdownButtonFormField<String>(
                value: _diff,
                decoration: const InputDecoration(labelText: 'Difficulty', prefixIcon: Icon(Icons.signal_cellular_alt, color: kBlue), border: InputBorder.none),
                items: ['Easy', 'Medium', 'Hard']
                    .map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _diff = v!),
              )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _busy ? null : _save,
                  child: _busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(_editing ? 'Update Recipe' : 'Recipe Save Karein',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 2),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: kBorder)),
    child: child,
  );

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType type = TextInputType.text, String? Function(String?)? v}) {
    return TextFormField(controller: c, keyboardType: type, validator: v,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: kBlue), border: InputBorder.none));
  }
}
