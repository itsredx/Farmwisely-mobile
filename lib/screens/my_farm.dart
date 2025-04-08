// ignore_for_file: prefer_final_fields, unused_field

import 'dart:convert'; // For JSON encoding
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
// Import the permission_handler package
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class MyFarm extends StatefulWidget {
  const MyFarm({super.key, required this.onPageChange});
  final Function(int) onPageChange;

  @override
  State<MyFarm> createState() => _MyFarmState();
}

class _MyFarmState extends State<MyFarm> {
  double _pHValue = 7.0; // Initial pH value
  String _selectedIrrigation = 'Manual'; // Default irrigation system
  TextEditingController _farmNameController =
      TextEditingController(); // Controller for TextField
  TextEditingController _farmLocationController =
      TextEditingController(); // Controller for TextField
  TextEditingController _farmSizeController =
      TextEditingController(); // Controller for TextField
  String _selectedSoilType = 'Choose your soil type'; // Default soil type
  String _selectedCurrentCrop = 'Choose your current crop'; // Default current crop
  String _selectedFutureCrop = 'Choose your future crop';
  bool _isLoading = true;
  String? _token;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('userId');
    if (token != null && userId != null) {
      setState(() {
        _token = token;
        _userId = userId;
        _loadData();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ignore: unused_element
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
          final Map<String, dynamic> decodedData = json.decode(response.body); // Now we are expecting a map and not a list
             setState(() {
                  _farmNameController.text = decodedData['farmName'] ?? '';
                  _farmLocationController.text = decodedData['farmLocation'] ?? '';
                  _farmSizeController.text = decodedData['farmSize'] ?? '';
                  _selectedSoilType = decodedData['soilType'] ?? 'Sandy';
                   _pHValue = decodedData['pHValue'] ?? 7.0;
                   _selectedCurrentCrop = decodedData['currentCrop'] ?? 'Maize';
                  _selectedFutureCrop = decodedData['futureCrop'] ?? 'Beans';
                   _selectedIrrigation = decodedData['irrigationSystem'] ?? 'Manual';
                 _isLoading = false;
               });
          } else {
                await _loadLocalData();
            _showError('Error loading data', response.body);
           setState(() {
              _isLoading = false;
            });
         }
      } else {
          await _loadLocalData();
          _showError(
            'Error loading data', 'No farm data found in shared preferences.');
          setState(() {
           _isLoading = false;
          });
       }
  } catch (e) {
      await _loadLocalData();
    _showError('Error loading data', e.toString());
      setState(() {
          _isLoading = false;
       });
 }
  }

  Future<void> _loadLocalData() async {
    // Get SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the saved JSON data (if it exists)
    String? jsonData = prefs.getString('farmData');

    // Print the raw JSON data to the console for debugging
    // Decode the JSON data
    Map<String, dynamic> decodedData = jsonDecode(jsonData!);
    setState(() {
      _farmNameController.text = decodedData['farmName'] ?? '';
      _farmLocationController.text = decodedData['farmLocation'] ?? '';
      _farmSizeController.text = decodedData['farmSize'] ?? '';
      _selectedSoilType = decodedData['soilType'] ?? 'Sandy';
      _pHValue = decodedData['pHValue'] ?? 7.0;
      _selectedCurrentCrop = decodedData['currentCrop'] ?? 'Maize';
      _selectedFutureCrop = decodedData['futureCrop'] ?? 'Beans';
      _selectedIrrigation = decodedData['irrigationSystem'] ?? 'Manual';
      _isLoading = false;
    });
    }

  Future<void> _saveData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final response = await http.post(
        Uri.parse('https://devred.pythonanywhere.com/api/farms/'),
        headers: {
          'Authorization': 'Token $_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'farmName': _farmNameController.text,
          'farmLocation': _farmLocationController.text,
          'farmSize': _farmSizeController.text,
          'soilType': _selectedSoilType,
          'pHValue': _pHValue,
          'currentCrop': _selectedCurrentCrop,
          'futureCrop': _selectedFutureCrop,
          'irrigationSystem': _selectedIrrigation,
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode == 201) {
        _showSuccess("farm data saved successfully");
        _loadData(); //reload data to update the list.
        final Map<String, dynamic> responseData =
            json.decode(response.body); //decode the response
        if (responseData.containsKey('id')) {
          await _saveLocalData(responseData['id']);
        }
      } else {
        _showError("Error", response.body);
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
    String farmName = _farmNameController.text;
    String farmLocation = _farmLocationController.text;
    String farmSize = _farmSizeController.text;

    // Prepare data
    final Map<String, dynamic> farmData = {
      'id': farmId, // include the farm id from the server
      'farmName': farmName, // Add farm name from TextField to JSON
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'soilType': _selectedSoilType, // Add soil type from dropdown to JSON
      'pHValue': _pHValue,
      'currentCrop': _selectedCurrentCrop,
      'futureCrop': _selectedFutureCrop,
      'irrigationSystem': _selectedIrrigation,
    };

    // Encode data to JSON
    String jsonData = jsonEncode(farmData);

    // Get SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'farmData', jsonData); // Save data in SharedPreferences
    await prefs.setInt(
        'farmId', farmId); //save farm id here // Save data in SharedPreferences
  }

  void _showError(String message, String details) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('$message\nDetails: $details'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Method to skip and go back to previous screen
  void _skip() {
    widget.onPageChange(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onPageChange(0);
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Up Your Farm Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage your farm',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farm Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Column(
                        children: [
                          TextField(
                            controller: _farmNameController,
                            decoration: const InputDecoration(
                              labelText: 'Farm Name',
                              hintText: 'Enter your farm name',
                              floatingLabelStyle:
                                  TextStyle(color: AppColors.secondary),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.secondary)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _farmLocationController,
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              hintText: 'Enter your farm location',
                              floatingLabelStyle:
                                  TextStyle(color: AppColors.secondary),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.secondary)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farm Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Column(
                        children: [
                          TextField(
                            controller: _farmSizeController,
                            decoration: const InputDecoration(
                              labelText: 'Farm Size',
                              hintText: 'Enter your farm size',
                              floatingLabelStyle:
                                  TextStyle(color: AppColors.secondary),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppColors.secondary)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 26,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Soil Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Soil Type',
                              hintText: _selectedSoilType,
                              floatingLabelStyle:
                                  const TextStyle(color: AppColors.secondary),
                              enabledBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                              border: const OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColors.secondary),
                              ),
                            ),
                            dropdownColor: AppColors
                                .secondary, // Background color for dropdown options
                            style: const TextStyle(
                              color: AppColors
                                  .grey, // Text color inside dropdown options
                              fontSize: 16, // Font size for dropdown options
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Sandy',
                                child: Text(
                                  'Sandy',
                                  style: TextStyle(
                                      color: AppColors.grey), // Text color
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Clay',
                                child: Text(
                                  'Clay',
                                  style: TextStyle(
                                      color: AppColors.grey), // Text color
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Loamy',
                                child: Text(
                                  'Loamy',
                                  style: TextStyle(
                                      color: AppColors.grey), // Text color
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              // Handle selection
                              setState(() {
                                _selectedSoilType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Soil pH Level',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'pH Value:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  Text(
                                    _pHValue
                                        .toStringAsFixed(1), // Display pH value
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Slider(
                                value: _pHValue,
                                min: 0.0,
                                max: 14.0,
                                divisions:
                                    70, // pH values range from 3.0 to 10.0
                                activeColor: AppColors.secondary,
                                inactiveColor: AppColors.grey,
                                onChanged: (value) {
                                  setState(() {
                                    _pHValue = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 26,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Crop Focus',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Column(
                            children: [
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Current Crop',
                                  hintText: _selectedCurrentCrop,
                                  floatingLabelStyle:
                                      TextStyle(color: AppColors.secondary),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.secondary),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.secondary),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.secondary),
                                  ),
                                ),
                                dropdownColor: AppColors
                                    .secondary, // Background color for dropdown options
                                style: const TextStyle(
                                  color: AppColors
                                      .grey, // Text color inside dropdown options
                                  fontSize:
                                      16, // Font size for dropdown options
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Maize',
                                    child: Text(
                                      'Maize',
                                      style: TextStyle(
                                          color: AppColors.grey), // Text color
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Rice',
                                    child: Text(
                                      'Rice',
                                      style: TextStyle(
                                          color: AppColors.grey), // Text color
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Beans',
                                    child: Text(
                                      'Beans',
                                      style: TextStyle(
                                          color: AppColors.grey), // Text color
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Handle selection
                                  setState(() {
                                    _selectedCurrentCrop = value!;
                                  });
                                },
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Future Crop',
                                  hintText: _selectedFutureCrop,
                                  floatingLabelStyle:
                                      TextStyle(color: AppColors.secondary),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.secondary),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.secondary),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppColors.secondary),
                                  ),
                                ),
                                dropdownColor: AppColors
                                    .secondary, // Background color for dropdown options
                                style: const TextStyle(
                                  color: AppColors
                                      .grey, // Text color inside dropdown options
                                  fontSize:
                                      16, // Font size for dropdown options
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Maize',
                                    child: Text(
                                      'Maize',
                                      style: TextStyle(
                                          color: AppColors.grey), // Text color
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Rice',
                                    child: Text(
                                      'Rice',
                                      style: TextStyle(
                                          color: AppColors.grey), // Text color
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Beans',
                                    child: Text(
                                      'Beans',
                                      style: TextStyle(
                                          color: AppColors.grey), // Text color
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  // Handle selection
                                  setState(() {
                                    _selectedFutureCrop = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 26.0),
                          const Text(
                            'Irrigation System',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RadioListTile<String>(
                                value: 'Manual',
                                groupValue: _selectedIrrigation,
                                title: const Text(
                                  'Manual',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIrrigation = value!;
                                  });
                                },
                                activeColor: AppColors.secondary,
                              ),
                              RadioListTile<String>(
                                value: 'Drip Irrigation',
                                groupValue: _selectedIrrigation,
                                title: const Text(
                                  'Drip Irrigation',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIrrigation = value!;
                                  });
                                },
                                activeColor: AppColors.secondary,
                              ),
                              RadioListTile<String>(
                                value: 'Sprinkler System',
                                groupValue: _selectedIrrigation,
                                title: const Text(
                                  'Sprinkler System',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIrrigation = value!;
                                  });
                                },
                                activeColor: AppColors.secondary,
                              ),
                              RadioListTile<String>(
                                value: 'Rain-fed',
                                groupValue: _selectedIrrigation,
                                title: const Text(
                                  'Rain-fed',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIrrigation = value!;
                                  });
                                },
                                activeColor: AppColors.secondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 26.0),
                          // Insight Section
                          const Text(
                            'Insight',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Setting up your farm profile helps us provide tailored weather updates, crop recommendations, and market insight.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey,
                            ),
                          ),
                          const SizedBox(height: 30.0),
                          // Save and Skip Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _skip, // Skip functionality
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.grey,
                                ),
                                child: const Text('Skip'),
                              ),
                              ElevatedButton(
                                onPressed: _saveData, // Save functionality
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: AppColors.secondary,
                                ),
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ]),
              ),
            ),
    );
  }
}
