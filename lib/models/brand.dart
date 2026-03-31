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
  }) : history = [];

  double get value => stock * price;
}