import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/order.dart'; // Tạo model Order từ JSON phản hồi của API
import 'package:shared_preferences/shared_preferences.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({super.key});

  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
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
        Uri.parse('http://localhost:3000/orders'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}'); // In ra mã trạng thái
      print('Response body: ${response.body}'); // In ra nội dung phản hồi

      if (response.statusCode == 200) {
        final List<dynamic> orderJson = json.decode(response.body);
        setState(() {
          _orders = orderJson.map((json) => Order.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load orders: ${response.statusCode} ${response.body}'),
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
        backgroundColor: Colors.orangeAccent,
        title: const Text('Order Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return Card(
                    child: ListTile(
                      title: Text('Customer: ${order.customerName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${order.orderDate}'),
                          Text('Total Amount: ${order.totalAmount} VND'),
                          Text('Status: ${order.status}'),
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
// Đoạn mã trên sẽ tạo một trang OrderListPage để hiển thị danh sách các đơn hàng. Trong hàm initState(), chúng ta gọi hàm _fetchOrders() để tải danh sách đơn hàng từ API. Trong hàm _fetchOrders(), chúng ta gửi yêu cầu GET đến API với token được lưu trong SharedPreferences. Nếu phản hồi trả về mã trạng thái 200, chúng ta chuyển đổi dữ liệu JSON thành danh sách các đối tượng Order và cập nhật trạng thái của trang. Nếu không, chúng ta hiển thị một SnackBar thông báo lỗi.