class Product {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.image,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      category: json['category'],
      image: json['image'],
    );
  }
}
// Compare this snippet from drink_shop/lib/models/order_detail.dart: