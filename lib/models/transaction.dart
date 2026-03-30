class Transaction {
  final DateTime timestamp;
  final String type; // "restock" or "sold"
  final int quantity;

  Transaction({
    required this.timestamp,
    required this.type,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'quantity': quantity,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      timestamp: DateTime.parse(json['timestamp']),
      type: json['type'],
      quantity: json['quantity'],
    );
  }
}