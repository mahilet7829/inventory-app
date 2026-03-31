import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/store_item.dart';
import '../models/brand.dart';
import '../models/transaction.dart';
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

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final String? data = prefs.getString('store_items');
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      setState(() {
        items = jsonList.map((json) => _storeItemFromJson(json)).toList();
      });
    }
  }

  Future<void> _saveItems() async {
    final jsonList = items.map((item) => _storeItemToJson(item)).toList();
    await prefs.setString('store_items', jsonEncode(jsonList));
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = searchQuery.isEmpty
        ? items
        : items.where((item) =>
            item.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soliyana Store'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search items (Fridge, Oven, Mixer...)',
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
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.kitchen_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('No items yet', style: TextStyle(fontSize: 22, color: Colors.grey)),
                        Text('Tap + to add your first item', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ItemScreen(storeItem: item)),
                        ).then((_) => _loadItems()),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.kitchen, size: 50, color: const Color(0xFF00D4FF)),
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
                                    color: item.totalStock > 0 ? Colors.greenAccent : Colors.redAccent,
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
            _saveItems();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // JSON Helpers
  Map<String, dynamic> _storeItemToJson(StoreItem item) {
    return {
      'id': item.id,
      'name': item.name,
      'brands': item.brands.map((b) => _brandToJson(b)).toList(),
    };
  }

  StoreItem _storeItemFromJson(Map<String, dynamic> json) {
    final item = StoreItem(id: json['id'], name: json['name']);
    item.brands = (json['brands'] as List).map((b) => _brandFromJson(b)).toList();
    return item;
  }

  Map<String, dynamic> _brandToJson(Brand brand) {
    return {
      'id': brand.id,
      'name': brand.name,
      'price': brand.price,
      'stock': brand.stock,
      'history': brand.history.map((h) => _transactionToJson(h)).toList(),
    };
  }

  Brand _brandFromJson(Map<String, dynamic> json) {
    final brand = Brand(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      stock: json['stock'],
    );
    brand.history = (json['history'] as List).map((h) => _transactionFromJson(h)).toList();
    return brand;
  }

  Map<String, dynamic> _transactionToJson(Transaction t) {
    return {
      'timestamp': t.timestamp.toIso8601String(),
      'type': t.type,
      'quantity': t.quantity,
    };
  }

  Transaction _transactionFromJson(Map<String, dynamic> json) {
    return Transaction(
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      quantity: json['quantity'],
    );
  }
}