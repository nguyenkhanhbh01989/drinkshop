import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_list_page.dart';
import 'order_list_page.dart';
import 'user_list_page.dart';
import 'login_page.dart';

class AdminPage extends StatelessWidget {
  static const Color buttonColor = Colors.orangeAccent;
  static const Color textColor = Colors.white;
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(horizontal: 50, vertical: 15);
  static final BorderRadius buttonBorderRadius = BorderRadius.circular(12.0);

  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: buttonColor,
        title: const Text('Admin Management'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              if (prefs.containsKey('token') && prefs.containsKey('role')) {
                await prefs.remove('token');
                await prefs.remove('role');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error logging out')),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildAdminButton(
              context,
              'Manage Products',
              const ProductListPage(),
            ),
            const SizedBox(height: 20),
            _buildAdminButton(
              context,
              'Manage Orders',
              const OrderListPage(),
            ),
            const SizedBox(height: 20),
            _buildAdminButton(
              context,
              'Manage Users',
              const UserListPage(),
            ),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildAdminButton(
    BuildContext context,
    String text,
    Widget page,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        foregroundColor: textColor,
        padding: buttonPadding,
        shape: RoundedRectangleBorder(
          borderRadius: buttonBorderRadius,
        ),
      ),
      child: Text(text),
    );
  }
}
