import 'brand.dart';

class StoreItem {
  final String id;
  String name;
  List<Brand> brands;

  StoreItem({
    required this.id,
    required this.name,
    List<Brand>? brands,
  }) : brands = brands ?? [];

  int get totalStock => brands.fold(0, (sum, b) => sum + b.stock);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'brands': brands.map((b) => b.toJson()).toList(),
  };

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'],
      name: json['name'],
      brands: (json['brands'] as List)
          .map((b) => Brand.fromJson(b))
          .toList(),
    );
  }
}