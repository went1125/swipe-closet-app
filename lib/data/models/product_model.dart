class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String deepLink;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.deepLink,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      price: (json['price'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      deepLink: json['shopUrl'] ?? '',
    );
  }
}