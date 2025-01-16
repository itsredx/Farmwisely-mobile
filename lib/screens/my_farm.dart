// ignore_for_file: prefer_final_fields

import 'package:farmwisely/utils/colors.dart';
import 'dart:convert'; // For JSON encoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String _selectedSoilType = 'Sandy'; // Default soil type
  String _selectedCurrentCrop = 'Maize'; // Default current crop
  String _selectedFutureCrop = 'Beans';

  // Method to save the data as JSON
  Future<void> _saveData() async {
    // Get text from the TextField
    String farmName = _farmNameController.text;
    String farmLocation = _farmLocationController.text;
    String farmSize = _farmSizeController.text;

    // Prepare data
    final Map<String, dynamic> farmData = {
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

    // Show a confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Farm data saved successfully!')),
    );
    _loadData();
  }

  // Method to skip and go back to previous screen
  void _skip() {
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    _loadData(); // Load the data when the widget is initialized
  }

  // Method to load and print the saved data
  Future<void> _loadData() async {
    // Get SharedPreferences instance
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the saved JSON data (if it exists)
    String? jsonData = prefs.getString('farmData');

    if (jsonData != null) {
      // Print the raw JSON data to the console for debugging

      print('Raw JSON Data: $jsonData');

      // Decode the JSON data
      Map<String, dynamic> decodedData = jsonDecode(jsonData);

      // Print the decoded data for debugging

      print('Decoded Data: $decodedData');
      /*
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Farm data $decodedData')));*/
    } else {
      print('No data found in SharedPreferences');
      /*
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data found in SharedPreferences')));*/
    }
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
      body: SingleChildScrollView(
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
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary)),
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
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary)),
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
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: AppColors.secondary)),
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
                      decoration: const InputDecoration(
                        labelText: 'Soil Type',
                        hintText: 'Choose your soil type',
                        floatingLabelStyle:
                            TextStyle(color: AppColors.secondary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.secondary),
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
                            style:
                                TextStyle(color: AppColors.grey), // Text color
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Clay',
                          child: Text(
                            'Clay',
                            style:
                                TextStyle(color: AppColors.grey), // Text color
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Loamy',
                          child: Text(
                            'Loamy',
                            style:
                                TextStyle(color: AppColors.grey), // Text color
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'pH Value:',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.grey,
                              ),
                            ),
                            Text(
                              _pHValue.toStringAsFixed(1), // Display pH value
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
                          min: 3.0,
                          max: 10.0,
                          divisions: 70, // pH values range from 3.0 to 10.0
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
                          decoration: const InputDecoration(
                            labelText: 'Current Crop',
                            hintText: 'Select crop you grow',
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
                            fontSize: 16, // Font size for dropdown options
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
                          decoration: const InputDecoration(
                            labelText: 'Future Crop',
                            hintText: 'Select crop you plan to grow',
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
                            fontSize: 16, // Font size for dropdown options
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
