import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/brand.dart';
import '../models/store_item.dart';
import '../models/transaction.dart';

class BrandDetailScreen extends StatefulWidget {
  final Brand brand;
  final StoreItem storeItem;

  const BrandDetailScreen({super.key, required this.brand, required this.storeItem});

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  final DateFormat dateFormat = DateFormat('dd MMM yyyy HH:mm');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.brand.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(widget.brand.name, 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text('Br ${widget.brand.price.toStringAsFixed(0)}', 
                        style: const TextStyle(fontSize: 32, color: Color(0xFF00D4FF), fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [
                          const Text('Stock'),
                          Text('${widget.brand.stock}', 
                              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                        ]),
                        Column(children: [
                          const Text('Total Value'),
                          Text('Br ${widget.brand.value.toStringAsFixed(0)}', 
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Restock & Sold Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        widget.brand.stock++;
                        widget.brand.history.insert(0, Transaction(
                          timestamp: DateTime.now(),
                          type: 'restock',
                          quantity: 1,
                        ));
                      });
                    },
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Restock (+1)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.brand.stock > 0 ? () {
                      setState(() {
                        widget.brand.stock--;
                        widget.brand.history.insert(0, Transaction(
                          timestamp: DateTime.now(),
                          type: 'sold',
                          quantity: -1,
                        ));
                      });
                    } : null,
                    icon: const Icon(Icons.remove_circle),
                    label: const Text('Sold (-1)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            const Text('Transaction History', 
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: widget.brand.history.isEmpty
                  ? const Center(child: Text('No transactions yet'))
                  : ListView.builder(
                      itemCount: widget.brand.history.length,
                      itemBuilder: (context, index) {
                        final t = widget.brand.history[index];
                        final isRestock = t.type == 'restock';
                        return ListTile(
                          leading: Icon(
                            isRestock ? Icons.add_circle : Icons.remove_circle,
                            color: isRestock ? Colors.green : Colors.red,
                            size: 30,
                          ),
                          title: Text(isRestock ? 'Restocked +1' : 'Sold -1',
                              style: const TextStyle(fontSize: 16)),
                          subtitle: Text(dateFormat.format(t.timestamp)),
                          trailing: Text(
                            isRestock 
                                ? '+ Br ${widget.brand.price.toStringAsFixed(0)}' 
                                : '- Br ${widget.brand.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: isRestock ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}