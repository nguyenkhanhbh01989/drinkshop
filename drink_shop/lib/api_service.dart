import 'package:http/http.dart' as http;

class ApiService {
  static Future<void> fetchData() async {
    final response = await http.get(Uri.parse('http://localhost:3000/data'));
    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}
