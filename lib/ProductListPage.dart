import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'model.dart';

class ProductService {
  final String baseUrl = 'https://stg-zero.propertyproplus.com.au/api/services/app/ProductSync';

  Future<List<Product>> fetchProducts(String accessToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/GetAllproduct'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Product.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch products');
    }
  }
}

class ProductPage extends StatefulWidget {
  final ProductService productService;
  final String accessToken;
   ProductPage({required this.productService, required this.accessToken});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFC2A6F6),
        title: Text('Product List page'),
      ),
      backgroundColor: Color(0xFFE8E1F5),
      body: FutureBuilder<List<Product>>(
        future: widget.productService.fetchProducts(widget.accessToken),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(product.description),
                  trailing: product.isAvailable ? Icon(Icons.check) : Icon(Icons.close),
                );
              },
            );
          } else {
            return Text('No data available');
          }
        },
      ),
    );
  }
}
