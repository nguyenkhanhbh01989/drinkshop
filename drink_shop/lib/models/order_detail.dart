class OrderDetail {
  final String productId;
  final int quantity;

  OrderDetail({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
    };
  }
}
// Compare this snippet from drink_shop/lib/models/order.dart: