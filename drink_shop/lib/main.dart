import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'admin_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drink Shop',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const SplashScreen(), // Kiểm tra trạng thái đăng nhập trước khi vào app
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    Map<String, dynamic> loginStatus = await checkLoginStatus();
    
    if (!mounted) return;

    // Kiểm tra role và điều hướng tương ứng
    if (loginStatus['isLoggedIn']) {
      if (loginStatus['role'] == 'admin') {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const AdminPage()));
      } else {
        Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } else {
      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Loading...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> checkLoginStatus() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.containsKey('token');
    String? role = prefs.getString('role') ?? "user"; // Mặc định là user nếu không có role
    return {'isLoggedIn': isLoggedIn, 'role': role};
  } catch (e) {
    print("Error checking login status: $e");
    return {'isLoggedIn': false, 'role': null}; // Trả về trạng thái mặc định nếu gặp lỗi
  }
}
