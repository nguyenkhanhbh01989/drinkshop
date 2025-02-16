import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/product.dart'; // Tạo model Product từ JSON phản hồi của API
import 'models/order_detail.dart'; // Tạo model OrderDetail

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Product> _products = [];
  List<OrderDetail> _cart = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('http://localhost:3000/products'));

      if (response.statusCode == 200) {
        final List<dynamic> productJson = json.decode(response.body);
        setState(() {
          _products = productJson.map((json) => Product.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load products: ${response.statusCode} ${response.body}'),
        ));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  void _addToCart(Product product) {
    setState(() {
      final existingOrderDetail = _cart.firstWhere(
        (item) => item.productId == product.id,
        orElse: () => OrderDetail(productId: '-1', quantity: 0),
      );

      if (existingOrderDetail.productId != '-1') {
        _cart = _cart.map((item) {
          if (item.productId == product.id) {
            return OrderDetail(productId: item.productId, quantity: item.quantity + 1);
          }
          return item;
        }).toList();
      } else {
        _cart.add(OrderDetail(productId: product.id, quantity: 1));
      }
    });
  }

  void _removeFromCart(OrderDetail orderDetail) {
    setState(() {
      final existingOrderDetail = _cart.firstWhere((item) => item.productId == orderDetail.productId);

      if (existingOrderDetail.quantity > 1) {
        _cart = _cart.map((item) {
          if (item.productId == orderDetail.productId) {
            return OrderDetail(productId: item.productId, quantity: item.quantity - 1);
          }
          return item;
        }).toList();
      } else {
        _cart.remove(orderDetail);
      }
    });
  }

  double _calculateTotal() {
    return _cart.fold(0, (sum, item) => sum + (item.quantity * _products.firstWhere((p) => p.id == item.productId).price));
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Cart is empty. Please add products to cart.'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      if (token == null) {
        throw 'Token is null';
      }

      final response = await http.post(
        Uri.parse('http://localhost:3000/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'customer_id': 'PLACEHOLDER_CUSTOMER_ID',
          'total_amount': _calculateTotal(),
          'status': 'Processing',
          'orderDetails': _cart.map((orderDetail) => orderDetail.toJson()).toList(),
        }),
      );

      if (response.statusCode == 201) {
        setState(() {
          _isLoading = false;
          _cart.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Order placed successfully'),
        ));
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to place order: ${response.statusCode} ${response.body}'),
        ));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Page'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        child: ListTile(
                          leading: Image.network(product.image),
                          title: Text(product.name),
                          subtitle: Text('${product.price} VND\n${product.description}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.add),
                            color: Colors.green,
                            onPressed: () => _addToCart(product),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 200.0, // Giới hạn chiều cao của giỏ hàng
                    child: Column(
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.orangeAccent,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final orderDetail = _cart[index];
                              final product = _products.firstWhere((p) => p.id == orderDetail.productId);
                              return Card(
                                child: ListTile(
                                  title: Text(product.name),
                                  subtitle: Text('${product.price} VND x ${orderDetail.quantity}'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.remove),
                                    color: Colors.red,
                                    onPressed: () => _removeFromCart(orderDetail),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Text('Total: ${_calculateTotal()} VND'),
                        ElevatedButton(
                          onPressed: _placeOrder,
                          child: const Text('Place Order'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}