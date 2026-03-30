import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/store_item.dart';
import 'create_item_screen.dart';
import 'item_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<StoreItem> items = [];
  String searchQuery = '';
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    await loadItems();
  }

  Future<void> loadItems() async {
    final String? data = prefs.getString('store_items');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        items = jsonList.map((json) => StoreItem.fromJson(json)).toList();
      });
    }
  }

  Future<void> saveItems() async {
    final List<Map<String, dynamic>> jsonList = 
        items.map((item) => item.toJson()).toList();
    await prefs.setString('store_items', jsonEncode(jsonList));
  }

  List<StoreItem> get filteredItems {
    if (searchQuery.isEmpty) return items;
    return items.where((item) =>
        item.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kitchen Stock'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search items (Fridge, Oven...)',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey[700]),
                        const SizedBox(height: 20),
                        const Text(
                          'No items yet',
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                        ),
                        const Text(
                          'Tap + to add your first item',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.05,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemScreen(storeItem: item),
                            ),
                          ).then((_) {
                            loadItems(); // refresh after returning
                          });
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.kitchen, size: 50, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(height: 12),
                                Text(
                                  item.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${item.totalStock} in stock',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: item.totalStock > 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newItem = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateItemScreen()),
          );
          if (newItem != null) {
            setState(() => items.add(newItem));
            saveItems();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}