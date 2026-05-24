// lib/screens/recipes/recipe_list_screen.dart
// Recipes ki list - Read, Delete, Add/Edit navigation

import 'package:flutter/material.dart';
import '../../models/recipe_db_model.dart';
import '../../services/recipe_service.dart';
import 'recipe_form_screen.dart';

const Color kBlue      = Color(0xFF4A90D9);
const Color kLightBlue = Color(0xFFE8F1FC);
const Color kBorder    = Color(0xFFD6E8F8);

class RecipeListScreen extends StatefulWidget {
  const RecipeListScreen({super.key});
  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<RecipeDB> _list    = [];
  bool           _loading = true;
  String?        _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      _list = await RecipeService.getAll();
    } catch (e) {
      _error = 'Server se connect nahi ho saka.\nNode.js backend chala raha hai? (node server.js)';
    }
    setState(() => _loading = false);
  }

  Future<void> _delete(RecipeDB r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recipe Delete Karein?'),
        content: Text('"${r.name}" delete ho jaye gi aur uske sare ingredients bhi.'),
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
      await RecipeService.delete(r.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe delete ho gayi!'), backgroundColor: Colors.red),
        );
      }
      _load();
    }
  }

  void _openForm({RecipeDB? r}) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeFormScreen(existing: r)));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        title: const Text('Recipes Manage Karein', style: TextStyle(fontWeight: FontWeight.w500)),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kBlue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nayi Recipe'),
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
          ? const Center(child: Text('Koi recipe nahi. + button dabao!'))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 80),
          itemCount: _list.length,
          itemBuilder: (_, i) => _Card(
            recipe: _list[i],
            onEdit:   () => _openForm(r: _list[i]),
            onDelete: () => _delete(_list[i]),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final RecipeDB     recipe;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _Card({required this.recipe, required this.onEdit, required this.onDelete});

  Color _dc() {
    if (recipe.difficulty == 'Easy') return Colors.green;
    if (recipe.difficulty == 'Hard') return Colors.red;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 80, height: 80,
            decoration: const BoxDecoration(
              color: kLightBlue,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
            ),
            child: Center(child: Text(recipe.emoji, style: const TextStyle(fontSize: 34))),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(recipe.category, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.timer_outlined, size: 12, color: kBlue),
                    const SizedBox(width: 3),
                    Text('${recipe.cookTime} min', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _dc().withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(recipe.difficulty, style: TextStyle(fontSize: 10, color: _dc(), fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          Column(children: [
            IconButton(icon: const Icon(Icons.edit_outlined, color: kBlue, size: 20), onPressed: onEdit),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20), onPressed: onDelete),
          ]),
        ],
      ),
    );
  }
}
