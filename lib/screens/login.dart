import 'dart:convert';
import 'package:farmwisely/main.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
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
  String? _token;
  int? _userId;
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
        _loadToken();
        //_loadFarmId();
        //_loadData();
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
        _loadToken();
        //_saveData();
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

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      setState(() {
        _token = token;
        _userId = userId;
        //_loadData();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFarmId() async {
    try {
      final response = await http.get(
        Uri.parse('https://devred.pythonanywhere.com/api/farms/'),
        headers: {
          'Authorization': 'Token $_token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> farmDataList = json.decode(response.body);
        if (farmDataList.isNotEmpty) {
          Map<String, dynamic> decodedData = farmDataList[0];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setInt('farmId', decodedData['id']); //store the farmId
        }
      } else {
        _showError('Error loading data', response.body);
      }
    } catch (e) {
      _showError('Error loading data', e.toString());
    }
  }

   Future<void> _loadData() async {
    setState(() {
        _isLoading = true; // Start loading
    });

    try {
          // First, try to get the farm ID from the shared preferences.
         final prefs = await SharedPreferences.getInstance();
         final int? farmId = prefs.getInt('farmId');

          if (farmId != null) {
            // Check if farmId exists if yes then fetch the data else set isloading to false
             final response = await http.get(
                 Uri.parse(
                  'https://devred.pythonanywhere.com/api/farms/$farmId/'), // Use the farm_id here
                  headers: {
                    'Authorization': 'Token $_token',
                  },
            );

               if (response.statusCode == 200) {
                 // Get SharedPreferences instance
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                 await prefs.setString('farmData', response.body); // save data as a string
                  setState(() {
                     _isLoading = false;
                   });
             } else {
                   _showError('Error loading data', response.body);
                    setState(() {
                      _isLoading = false;
                   });
                }
        } else {
            _showError(
                'No farm data found', 'Make sure that you have created a farm profile');
              setState(() {
                  _isLoading = false;
               });
         }
        } catch (e) {
            _showError('An error occurred', e.toString());
           setState(() {
                _isLoading = false;
              });
       }
  }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Check location permission before getting position
      final permissionStatus = await Permission.location.request();
      if (permissionStatus.isGranted) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        final response = await http.post(
          Uri.parse('https://devred.pythonanywhere.com/api/farms/'),
          headers: {
            'Authorization': 'Token $_token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'farmName': '',
            'farmLocation': '',
            'farmSize': '',
            'soilType': '',
            'pHValue': 7,
            'currentCrop': '',
            'futureCrop': '',
            'irrigationSystem': '',
            'latitude': 000.0,
            'longitude': 000.0,
          }),
        );

        if (response.statusCode == 201) {
          _showSuccess("farm data saved successfully");
          final Map<String, dynamic> responseData =
              json.decode(response.body); //decode the response
          if (responseData
              .containsKey('id')) //check if the response body has a key id
          {
            await _saveLocalData(responseData[
                'id']); // save the farm id to local preferences using the same function
          }

          //_loadData();
        } else {
          _showError("Error", response.body);
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        //Permission not granted
        _showError("Error", 'Location permission not granted');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _showError("Error:", e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveLocalData(int farmId) async {
    // Get text from the TextField
    String farmName = '';
    String farmLocation = '';
    String farmSize = '';

    // Prepare data
    final Map<String, dynamic> farmData = {
      'id': farmId, // include the farm id from the server
      'farmName': farmName, // Add farm name from TextField to JSON
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'soilType': '', // Add soil type from dropdown to JSON
      'pHValue': '',
      'currentCrop': '',
      'futureCrop': '',
      'irrigationSystem': '',
    };

    // Encode data to JSON
    String jsonData = jsonEncode(farmData);

    // Get SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'farmData', jsonData); // Save data in SharedPreferences
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
