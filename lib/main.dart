import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'ProductListPage.dart';


void main() {
  runApp(MyApp());
}

class AuthService {
  final storage = FlutterSecureStorage();
  final apiUrl = 'https://stg-zero.propertyproplus.com.au/api';

  Future<String?> authenticate(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/TokenAuth/Authenticate'),
        headers: {
          'Abp.TenantId': '10',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userNameOrEmailAddress': username,
          'password': password,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 && responseBody['success'] == true) {
        final token = responseBody['result']['accessToken'];
        if (token != null && token.isNotEmpty) {
          await storage.write(key: 'access_token', value: token);
          return token;
        } else {
          throw Exception('Access token is missing or empty');
        }
      }

      throw Exception('Failed to authenticate');
    } catch (e) {
      print('Authentication error: $e');
      throw Exception('Failed to authenticate');
    }
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }
}

class MyApp extends StatelessWidget {
  final authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(authService: authService),
    );
  }
}

class LoginPage extends StatefulWidget {
  final AuthService authService;

  LoginPage({required this.authService});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ProductService productService = ProductService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    try {
      final token = await widget.authService.authenticate(username, password);
      if (token != null) {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductPage(
          productService: productService,
          accessToken: token,)));
        print('Login successful');
      }
    } catch (e) {
      // Handle authentication error
      print('Authentication error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E1F5),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 150,),

              Text('Login',
                  style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold)
              ),
              Padding(
                padding: const EdgeInsets.only(top:20,left: 30.0,right: 30.0),
                child: TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Colors.deepPurple)
                      ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.deepPurple)
                        ),
                        labelText: 'Username',

                    ),
                keyboardType: TextInputType.name,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top:20,left: 30.0,right: 30.0,bottom: 50),
                child: TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple)
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                              color: Colors.deepPurple)
                      ),
                        labelText: 'Password',
                    ),
                ),
              ),
              SizedBox(
                width: 120,height: 50,
                child: ElevatedButton(onPressed: _login,
                    child: Text('Login',
                    ),
                ),
              ),
              TextButton(
                  onPressed: () {
                  },
                  child: const Text('Don\'t have an Account?')),
              TextButton(
                  onPressed: () {
                  },
                  child: const Text('Forget Password')),
            ],
          ),
        ),
      ),
    );
  }
}


// class ProductPage extends StatelessWidget {
//   const ProductPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Product page'),
//       ),
//     );
//   }
// }