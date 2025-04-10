import 'dart:convert';
import 'package:farmwisely/main.dart';
// Import the new screen
import 'package:farmwisely/screens/auth/set_profile_details_screen.dart'; // Import the new screen
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
// Remove unused imports if Geolocator/Permission handler are no longer used here
// import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  late TabController _tabController;
  // Keep token/userId if needed for immediate feedback, but they aren't strictly necessary
  // String? _token;
  // int? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message, String details) {
    if (!mounted) return;
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
    if (!mounted) return;
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
        await prefs.setString('token', token);
        await prefs.setInt('userId', userId);

        // On Login, go directly to MyApp (assuming profile exists)
        // A more robust app might check if farmId exists here or in MyApp's loading
        _showSuccess("Logged in Successfully");
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
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
      // Ensure isLoading is set to false even if widget is disposed during async call
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
    });
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;
    try {
      final response = await http.post(
        Uri.parse('https://devred.pythonanywhere.com/api/auth/register/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email
        }),
      );

      if (response.statusCode == 201) {
        final decodedData = json.decode(response.body);
        final String token = decodedData['token'];
        final int userId = decodedData['user_id'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('userId', userId);

        _showSuccess("Signed Up Successfully! Please create your farm profile.");

        // **** CHANGE HERE: Navigate to CreateFarmProfileScreen ****
        Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              // Navigate to the new screen
              builder: (context) => SetProfileDetailsScreen(
                userEmail: email, // Pass the captured email
              ),
            ));
         // **** END CHANGE ****

      } else {
        _showError("Sign Up Failed", response.body);
      }
    } catch (e) {
      _showError('An error occurred', e.toString());
    } finally {
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Remove unused methods _loadToken, _loadFarmId, _loadData, _saveData, _saveLocalData
  // as they are no longer needed in this screen's logic

  @override
  Widget build(BuildContext context) {
    // ... Keep the existing build method structure for LoginScreen ...
    // (The UI with TabBar, TextFields, Buttons remains the same)
     return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Login or Sign up'),
        centerTitle: true,
        bottom: TabBar(
          // used the tab bar
          controller: _tabController,
          indicatorColor: AppColors.secondary, // Added indicator color
          labelColor: AppColors.secondary, // Added label color
          unselectedLabelColor: Colors.grey, // Added unselected label color
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
                  _buildLoginForm(), // Extracted to a method for clarity
                  // Sign Up Tab
                  _buildSignupForm(), // Extracted to a method for clarity
                ],
              ),
            ),
    );
  }

   // Extracted Login Form Widget
   Widget _buildLoginForm() {
     return Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: <Widget>[
         TextField(
           controller: _usernameController,
           decoration: _inputDecoration('Username'), // Use helper
         ),
         const SizedBox(height: 20),
         TextField(
           controller: _passwordController,
           obscureText: true,
           decoration: _inputDecoration('Password'), // Use helper
         ),
         const SizedBox(height: 30),
         ElevatedButton(
           onPressed: _login,
           style: ElevatedButton.styleFrom(
             backgroundColor: AppColors.secondary,
             padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
             textStyle: const TextStyle(fontSize: 16),
           ),
           child: const Text(
             'Login',
             style: TextStyle(color: AppColors.grey),
           ),
         ),
       ],
     );
   }

   // Extracted Signup Form Widget
    Widget _buildSignupForm() {
     return Column(
       mainAxisAlignment: MainAxisAlignment.center,
       children: <Widget>[
         TextField(
           controller: _usernameController, // Re-use controller or use separate ones if needed
           decoration: _inputDecoration('Username'), // Use helper
         ),
         const SizedBox(height: 20),
         TextField(
           controller: _emailController,
           decoration: _inputDecoration('Email'), // Use helper
           keyboardType: TextInputType.emailAddress,
         ),
         const SizedBox(height: 20),
         TextField(
           controller: _passwordController, // Re-use controller or use separate ones if needed
           obscureText: true,
           decoration: _inputDecoration('Password'), // Use helper
         ),
         const SizedBox(height: 30),
         ElevatedButton(
           onPressed: _signup,
           style: ElevatedButton.styleFrom(
             backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
             textStyle: const TextStyle(fontSize: 16),
           ),
           child: const Text(
             'Sign Up',
             style: TextStyle(color: AppColors.grey),
           ),
         ),
       ],
     );
   }

   // Input decoration helper (can be shared or kept within LoginScreen)
    InputDecoration _inputDecoration(String label) {
     return InputDecoration(
       labelText: label,
       floatingLabelStyle: const TextStyle(color: AppColors.secondary),
       enabledBorder: const OutlineInputBorder(
         borderSide: BorderSide(color: AppColors.secondary),
       ),
       focusedBorder: const OutlineInputBorder(
         borderSide: BorderSide(color: AppColors.secondary, width: 2.0),
       ),
       border: const OutlineInputBorder(
           borderSide:
               BorderSide(color: AppColors.secondary)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
     );
   }
}