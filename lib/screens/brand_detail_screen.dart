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
  final DateFormat dateFormat = DateFormat('dd MMM yyyy  HH:mm');

  @override
  void initState() {
    super.initState();
    // Show warning immediately if stock is already 0 when opening the screen
    if (widget.brand.stock == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOutOfStockNotification();
      });
    }
  }

  // Show notification when stock is 0
  void _showOutOfStockNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'You are out of ${widget.brand.name}, please restock',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show notification automatically when stock becomes 0
    if (widget.brand.stock == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOutOfStockNotification();
      });
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.brand.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(widget.brand.name, 
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(
                      'ብር ${widget.brand.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 32, color: Color(0xFF00D4FF), fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('Current Stock'),
                            Text(
                              '${widget.brand.stock}',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: widget.brand.stock == 0 ? Colors.red : Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('Total Value'),
                            Text('ብር ${widget.brand.value.toStringAsFixed(0)}', 
                                style: const TextStyle(fontSize: 24)),
                          ],
                        ),
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
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Restock (+1)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
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
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.remove_circle_outline),
                    label: const Text('Sold (-1)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () {
                      if (widget.brand.stock <= 0) {
                        _showOutOfStockNotification();
                        return;
                      }
                      setState(() {
                        widget.brand.stock--;
                        widget.brand.history.insert(0, Transaction(
                          timestamp: DateTime.now(),
                          type: 'sold',
                          quantity: -1,
                        ));
                      });
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // History
            const Text('Transaction History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                          ),
                          title: Text(isRestock ? 'Restocked +1' : 'Sold -1'),
                          subtitle: Text(dateFormat.format(t.timestamp)),
                          trailing: Text(
                            isRestock 
                                ? '+ ብር ${widget.brand.price.toStringAsFixed(0)}' 
                                : '- ብር ${widget.brand.price.toStringAsFixed(0)}',
                            style: TextStyle(color: isRestock ? Colors.green : Colors.red),
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