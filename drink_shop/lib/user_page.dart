import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Map<String, String> _userInfo = {};
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      // Thay thế localhost bằng URL ngrok
      final userResponse =
          await http.get(Uri.parse('http://localhost:3000/user'));
      final orderResponse =
          await http.get(Uri.parse('http://localhost:3000/orders'));

      if (userResponse.statusCode == 200 && orderResponse.statusCode == 200) {
        final userJson = json.decode(userResponse.body);
        final orderJson = json.decode(orderResponse.body);

        setState(() {
          _userInfo = {
            'name': userJson['name'],
            'email': userJson['email'],
            'phone': userJson['phone'],
            'address': userJson['address'],
          };
          _orders = List<Map<String, dynamic>>.from(orderJson);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Failed to load data: ${userResponse.statusCode} ${orderResponse.statusCode}'),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('User Information'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: ListTile(
                      title: const Text('Name'),
                      subtitle: Text(_userInfo['name'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Email'),
                      subtitle: Text(_userInfo['email'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Phone'),
                      subtitle: Text(_userInfo['phone'] ?? 'N/A'),
                    ),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text('Address'),
                      subtitle: Text(_userInfo['address'] ?? 'N/A'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _orders.length,
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        return Card(
                          child: ListTile(
                            title: Text('Order ID: ${order['orderId']}'),
                            subtitle: Text(
                                'Date: ${order['date']} \nTotal: ${order['total']} VND'),
                            trailing: Text(
                              order['status'],
                              style: TextStyle(
                                color: order['status'] == 'Completed'
                                    ? Colors.green
                                    : order['status'] == 'Processing'
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
