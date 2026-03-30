import 'transaction.dart';

class Brand {
  final String id;
  String name;
  double price;
  int stock;
  List<Transaction> history;

  Brand({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    List<Transaction>? history,
  }) : history = history ?? [];

  int get value => (price * stock).toInt();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'stock': stock,
    'history': history.map((h) => h.toJson()).toList(),
  };

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      stock: json['stock'],
      history: (json['history'] as List)
          .map((h) => Transaction.fromJson(h))
          .toList(),
    );
  }
}