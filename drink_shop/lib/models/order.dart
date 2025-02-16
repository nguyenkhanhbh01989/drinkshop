class Order {
  final String id;
  final String customerName;
  final DateTime orderDate;
  final double totalAmount;
  final String status;

  Order({
    required this.id,
    required this.customerName,
    required this.orderDate,
    required this.totalAmount,
    required this.status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerName: json['customer_id']['name'],
      orderDate: DateTime.parse(json['order_date']),
      totalAmount: json['total_amount'].toDouble(),
      status: json['status'],
    );
  }
}
