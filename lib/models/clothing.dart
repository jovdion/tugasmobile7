class Clothing {
  final int? id;
  final String name;
  final int price;
  final String category;
  final String brand;
  final int sold;
  final double rating;
  final int stock;
  final int yearReleased;
  final String material;

  Clothing({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.brand,
    required this.sold,
    required this.rating,
    required this.stock,
    required this.yearReleased,
    required this.material,
  });

  factory Clothing.fromJson(Map<String, dynamic> json) {
    return Clothing(
      id: json['id'],
      name: json['name'] ?? '',
      price: _parseToInt(json['price']),
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      sold: _parseToInt(json['sold']),
      rating: _parseToDouble(json['rating']),
      stock: _parseToInt(json['stock']),
      yearReleased: _parseToInt(json['yearReleased']),
      material: json['material'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'brand': brand,
      'sold': sold,
      'rating': rating,
      'stock': stock,
      'yearReleased': yearReleased,
      'material': material,
    };
  }

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}