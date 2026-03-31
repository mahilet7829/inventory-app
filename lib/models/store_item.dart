import 'brand.dart';

class StoreItem {
  final String id;
  String name;
  List<Brand> brands;

  StoreItem({required this.id, required this.name}) : brands = [];

  int get totalStock => brands.fold(0, (sum, b) => sum + b.stock);
}