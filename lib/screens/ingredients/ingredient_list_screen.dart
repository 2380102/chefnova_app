
import 'package:flutter/material.dart';
import '../../models/ingredient_model.dart';
import '../../services/ingredient_service.dart';
import 'ingredient_form_screen.dart';

const Color kBlue      = Color(0xFF4A90D9);
const Color kLightBlue = Color(0xFFE8F1FC);
const Color kBorder    = Color(0xFFD6E8F8);

class IngredientListScreen extends StatefulWidget {
  const IngredientListScreen({super.key});
  @override
  State<IngredientListScreen> createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  List<Ingredient> _list    = [];
  bool             _loading = true;
  String?          _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _list = await IngredientService.getAll();
    } catch (e) {
      _error = 'Server se connect nahi ho saka.\nNode.js backend chala raha hai? (node server.js)';
    }
    setState(() => _loading = false);
  }

  Future<void> _delete(Ingredient ing) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ingredient Delete Karein?'),
        content: Text('"${ing.name}" delete kar dein?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await IngredientService.delete(ing.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient delete ho gaya!'), backgroundColor: Colors.red),
        );
      }
      _load();
    }
  }

  void _openForm({Ingredient? ing}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => IngredientFormScreen(existing: ing)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: const Text('Ingredients Manage Karein', style: TextStyle(fontWeight: FontWeight.w500)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Naya Ingredient'),
        onPressed: () => _openForm(),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kBlue))
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Dobara Try Karein'),
                style: ElevatedButton.styleFrom(backgroundColor: kBlue, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      )
          : _list.isEmpty
          ? const Center(child: Text('Koi ingredient nahi. + button dabao!'))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
          itemCount: _list.length,
          itemBuilder: (_, i) => _Card(
            ing:      _list[i],
            onEdit:   () => _openForm(ing: _list[i]),
            onDelete: () => _delete(_list[i]),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Ingredient   ing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _Card({required this.ing, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: kLightBlue, shape: BoxShape.circle),
            child: const Center(child: Icon(Icons.kitchen_outlined, color: kBlue, size: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ing.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Row(children: [
                  Text('${ing.quantity} ${ing.unit}', style: const TextStyle(color: kBlue, fontSize: 12)),
                  if (ing.recipeName != null) ...[
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Flexible(child: Text(ing.recipeName!, style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis)),
                  ],
                ]),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined, color: kBlue, size: 20), onPressed: onEdit),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
        ],
      ),
    );
  }
}
