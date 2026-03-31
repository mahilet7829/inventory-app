import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/store_item.dart';
import '../models/brand.dart';
import 'create_brand_screen.dart';
import 'brand_detail_screen.dart';

class ItemScreen extends StatefulWidget {
  final StoreItem storeItem;

  const ItemScreen({super.key, required this.storeItem});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.storeItem.name)),
      body: widget.storeItem.brands.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No brands added yet', style: TextStyle(fontSize: 20)),
                  Text('Tap + to add brands for this item', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.storeItem.brands.length,
              itemBuilder: (context, index) {
                final brand = widget.storeItem.brands[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(brand.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ብር ${brand.price.toStringAsFixed(0)}'),
                        Text(
                          'Stock: ${brand.stock}',
                          style: TextStyle(
                            color: brand.stock > 0 ? Colors.greenAccent : Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      'ብር ${brand.value.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BrandDetailScreen(
                            brand: brand,
                            storeItem: widget.storeItem,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newBrand = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateBrandScreen(storeItem: widget.storeItem),
            ),
          );
          if (newBrand != null) {
            setState(() {
              widget.storeItem.brands.add(newBrand);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}