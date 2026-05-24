// lib/screens/ingredients/ingredient_form_screen.dart
// Add aur Edit Ingredient form

import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';
import '../../models/recipe_db_model.dart';
import '../../services/ingredient_service.dart';
import '../../services/recipe_service.dart';

const Color kBlue   = Color(0xFF4A90D9);
const Color kBorder = Color(0xFFD6E8F8);

class IngredientFormScreen extends StatefulWidget {
  final Ingredient? existing;
  const IngredientFormScreen({super.key, this.existing});
  @override
  State<IngredientFormScreen> createState() => _IngredientFormScreenState();
}

class _IngredientFormScreenState extends State<IngredientFormScreen> {
  final _key = GlobalKey<FormState>();
  late TextEditingController _name, _qty, _unit;
  List<RecipeDB> _recipes    = [];
  int?           _recipeId;
  bool           _busy       = false;
  bool           _loadingRec = true;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name     ?? '');
    _qty  = TextEditingController(text: e?.quantity ?? '');
    _unit = TextEditingController(text: e?.unit     ?? '');
    _recipeId = e?.recipeId;
    _loadRecipes();
  }

  @override
  void dispose() { _name.dispose(); _qty.dispose(); _unit.dispose(); super.dispose(); }

  Future<void> _loadRecipes() async {
    try {
      final list = await RecipeService.getAll();
      setState(() {
        _recipes    = list;
        _loadingRec = false;
        _recipeId ??= list.isNotEmpty ? list.first.id : null;
      });
    } catch (_) { setState(() => _loadingRec = false); }
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    if (_recipeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recipe select karein')));
      return;
    }
    setState(() => _busy = true);

    final ing = Ingredient(
      recipeId: _recipeId!, name: _name.text.trim(),
      quantity: _qty.text.trim(), unit: _unit.text.trim(),
    );

    final ok = _editing
        ? await IngredientService.update(widget.existing!.id!, ing)
        : await IngredientService.create(ing);

    setState(() => _busy = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? (_editing ? '✅ Update ho gaya!' : '✅ Ingredient add ho gaya!') : '❌ Error! Dobara try karein.'),
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
        title: Text(_editing ? 'Ingredient Edit Karein' : 'Naya Ingredient Add Karein',
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
      body: _loadingRec
          ? const Center(child: CircularProgressIndicator(color: kBlue))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _key,
          child: Column(
            children: [
              // Recipe select karo
              _box(_recipes.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: Text('Pehle recipe banao!', style: TextStyle(color: Colors.red)),
              )
                  : DropdownButtonFormField<int>(
                value: _recipeId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Recipe Select Karein',
                  prefixIcon: Icon(Icons.restaurant_menu, color: kBlue),
                  border: InputBorder.none,
                ),
                items: _recipes.map((r) => DropdownMenuItem(
                  value: r.id,
                  child: Text('${r.emoji} ${r.name}', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (v) => setState(() => _recipeId = v),
              )),
              const SizedBox(height: 10),
              _box(_field(_name, 'Ingredient ka Naam (jaise Chicken)', Icons.egg_alt_outlined,
                  v: (s) => s!.isEmpty ? 'Naam likhein' : null)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(flex: 2, child: _box(_field(_qty, 'Quantity', Icons.numbers,
                    type: TextInputType.number, v: (s) => s!.isEmpty ? 'Likhein' : null))),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _box(_field(_unit, 'Unit (g, cup, tbsp)', Icons.scale_outlined))),
              ]),
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
                      : Text(_editing ? 'Update Karein' : 'Ingredient Save Karein',
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
