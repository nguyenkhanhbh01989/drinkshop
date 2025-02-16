import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/product.dart'; // Tạo model Product từ JSON phản hồi của API
import 'package:shared_preferences/shared_preferences.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> _products = [];
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print('Token: $token'); // In token ra để kiểm tra

      if (token == null) {
        throw 'Token is null';
      }

      final response = await http.get(
        Uri.parse('http://localhost:3000/products'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}'); // In ra mã trạng thái
      print('Response body: ${response.body}'); // In ra nội dung phản hồi

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

  Future<void> _deleteProduct(Product product) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw 'Token is null';
      }

      final response = await http.delete(
        Uri.parse('http://localhost:3000/products/${product.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _products.remove(product);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to delete product: ${response.statusCode} ${response.body}'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  void _editProduct(Product product) {
    // Xử lý logic chỉnh sửa sản phẩm
  }

  void _addProduct() {
    // Xử lý logic thêm sản phẩm mới
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Product List'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addProduct,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Card(
                    child: ListTile(
                      leading: Image.network(product.image),
                      title: Text(product.name),
                      subtitle: Text('${product.price} VND\n${product.description}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(Icons.edit),
                            color: Colors.blue,
                            onPressed: () => _editProduct(product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => _deleteProduct(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
