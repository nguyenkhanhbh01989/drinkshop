import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Text('Product Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Image.asset(
                product['image'],
                height: 200,
                width: 200,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '${product['price']} VND',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orangeAccent,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: product['reviews'].length,
                itemBuilder: (context, index) {
                  final review = product['reviews'][index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.star,
                        color: Colors.yellow[700],
                      ),
                      title: Text(review['customer']),
                      subtitle: Text(review['comment']),
                      trailing: Text(
                        '${review['rating']} / 5',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
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
