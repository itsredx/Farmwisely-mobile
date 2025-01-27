import 'dart:convert';
import 'package:farmwisely/main.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(); // Added email controller
  bool _isLoading = false;
  late TabController _tabController; // Added the tab controller
  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); //initializes the tab controller
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showError(String message, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text('$message\nDetails: $details'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('https://devred.pythonanywhere.com/api/auth/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final String token = decodedData['token'];
        final int userId = decodedData['user_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // store the token
        await prefs.setInt('userId', userId); // store the user id
        _showSuccess("Logged in Successfully");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MyApp(
              isLoggedIn: true,
            ),
          ),
        );
      } else {
        _showError("Login Failed", response.body);
      }
    } catch (e) {
      _showError('An error occurred', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text; // Get the email
    try {
      final response = await http.post(
        Uri.parse('https://devred.pythonanywhere.com/api/auth/register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email // Send the email in the request
        }),
      );

      if (response.statusCode == 201) {
        final decodedData = json.decode(response.body);
        final String token = decodedData['token'];
        final int userId = decodedData['user_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token); // store the token
        await prefs.setInt('userId', userId); // store the user id
        _showSuccess("Signed Up Successfully");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MyApp(
                      isLoggedIn: true,
                    )));
      } else {
        _showError("Sign Up Failed", response.body);
      }
    } catch (e) {
      _showError('An error occurred', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Login or Sign up'),
        centerTitle: true,
        bottom: TabBar(
          // used the tab bar
          controller: _tabController,
          tabs: const [
            Tab(text: 'Login'),
            Tab(text: 'Sign Up'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Login Tab
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          floatingLabelStyle:
                              TextStyle(color: AppColors.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.secondary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          floatingLabelStyle:
                              TextStyle(color: AppColors.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.secondary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                  // Sign Up Tab
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          floatingLabelStyle:
                              TextStyle(color: AppColors.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.secondary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _emailController, // Email field in sign up
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          floatingLabelStyle:
                              TextStyle(color: AppColors.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.secondary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          floatingLabelStyle:
                              TextStyle(color: AppColors.secondary),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary),
                          ),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppColors.secondary)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
