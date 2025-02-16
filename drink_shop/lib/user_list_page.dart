import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Lấy token từ SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      print('Token: $token'); // In token ra để kiểm tra

      if (token == null) {
        throw 'Token is null';
      }

      final response = await http.get(
        Uri.parse('http://localhost:3000/users'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}'); // In ra mã trạng thái
      print('Response body: ${response.body}'); // In ra nội dung phản hồi

      if (response.statusCode == 200) {
        final List<dynamic> userJson = json.decode(response.body);
        setState(() {
          _users = userJson.map((json) => User.fromJson(json)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load users: ${response.statusCode} ${response.body}'),
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
        title: const Text('User Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  child: ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Text(user.phone),
                  ),
                );
              },
            ),
    );
  }
}
