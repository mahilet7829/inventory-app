class Transaction {
  final DateTime timestamp;
  final String type; // "restock" or "sold"
  final int quantity;

  Transaction({
    required this.timestamp,
    required this.type,
    required this.quantity,
  });
}