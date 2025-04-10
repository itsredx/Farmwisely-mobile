// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:farmwisely/main.dart'; // To navigate to MyApp
import 'package:farmwisely/utils/colors.dart'; // Your colors
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateFarmProfileScreen extends StatefulWidget {
  const CreateFarmProfileScreen({super.key});

  @override
  State<CreateFarmProfileScreen> createState() =>
      _CreateFarmProfileScreenState();
}

class _CreateFarmProfileScreenState extends State<CreateFarmProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // For form validation

  // Controllers for text fields
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _farmLocationController = TextEditingController();
  final TextEditingController _farmSizeController = TextEditingController();

  // State variables for dropdowns, slider, radio buttons
  String? _selectedSoilType; // Start as null for validation
  double _pHValue = 7.0; // Initial pH value
  String? _selectedCurrentCrop; // Start as null
  String? _selectedFutureCrop; // Start as null
  String _selectedIrrigation = 'Manual'; // Default irrigation system

  double? _latitude;
  double? _longitude;
  String? _token;
  bool _isLoading = false;
  bool _isGettingLocation = false;

  // Define the choices (MUST match backend choices exactly if possible, case-sensitive)
  // Check your Django models.CharField(choices=...) definition
  final List<String> _soilTypes = ['Sandy', 'Clay', 'Loamy', 'Silty', 'Peaty', 'Chalky']; // Example list, adjust based on backend
  final List<String> _cropTypes = ['Maize', 'Rice', 'Beans', 'Wheat', 'Tomato', 'Cotton', 'Other']; // Example list
  final List<String> _irrigationOptions = ['Manual', 'Drip Irrigation', 'Sprinkler System', 'Rain-fed']; // Example list


  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  void dispose() {
    // Dispose controllers
    _farmNameController.dispose();
    _farmLocationController.dispose();
    _farmSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('token');
    });
    if (_token == null) {
      _showError('Authentication Error',
          'Could not load user token. Please login again.');
      // Optionally navigate back to login
       Navigator.of(context).pop(); // Go back if token is missing
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });
    try {
      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied) {
        status = await Permission.locationWhenInUse.request();
      }

      if (status.isGranted) {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          _showError('Location Error',
              'Location services are disabled. Please enable them.');
          setState(() => _isGettingLocation = false);
          return;
        }

        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _isGettingLocation = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location Acquired Successfully!')),
          );
        });
      } else if (status.isPermanentlyDenied) {
        _showError('Permission Error',
            'Location permission is permanently denied. Please enable it in app settings.');
        setState(() => _isGettingLocation = false);
        // Optionally open app settings:
         openAppSettings();
      } else {
        _showError('Permission Error', 'Location permission denied.');
        setState(() {
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      _showError('Location Error', 'Could not get location: ${e.toString()}');
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _saveFarmProfile() async {
    if (_token == null) {
      _showError('Error', 'Authentication token not found.');
      return;
    }

    // Validate the entire form first
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Ensure latitude and longitude have default values if not acquired
        final double latToSend = _latitude ?? 0.0;
        final double lonToSend = _longitude ?? 0.0;

        final response = await http.post(
          Uri.parse('https://devred.pythonanywhere.com/api/farms/'),
          headers: {
            'Authorization': 'Token $_token',
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json.encode({
            // Text Fields
            'farmName': _farmNameController.text,
            'farmLocation': _farmLocationController.text,
            'farmSize': _farmSizeController.text,
            // Dropdowns, Slider, Radio Buttons
            'soilType': _selectedSoilType,       // Send selected value
            'pHValue': _pHValue,               // Send slider value
            'currentCrop': _selectedCurrentCrop, // Send selected value
            'futureCrop': _selectedFutureCrop,   // Send selected value
            'irrigationSystem': _selectedIrrigation, // Send selected value
            // Location
            'latitude': latToSend,
            'longitude': lonToSend,
          }),
        );

        if (response.statusCode == 201) {
          _showSuccess("Farm Profile Created Successfully!");
          final Map<String, dynamic> responseData = json.decode(response.body);
          if (responseData.containsKey('id')) {
            final int farmId = responseData['id'];
            final prefs = await SharedPreferences.getInstance();
            await prefs.setInt('farmId', farmId); // Save the farm ID
            await prefs.setString('farmData', response.body); // Save full data

            // Navigate to the main app screen
            Navigator.pushReplacement(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => const MyApp(isLoggedIn: true),
              ),
            );
          } else {
            _showError('Error', 'Farm ID not found in response.');
          }
        } else {
           // Try to decode the error response for better details
           String errorDetails = response.body;
           try {
             final decodedError = json.decode(response.body);
             // Format the error nicely if possible
             errorDetails = decodedError.entries.map((e) => '${e.key}: ${e.value.join(', ')}').join('\n');
           } catch (_) {
             // Keep original body if decoding fails
           }
           _showError("Failed to Create Profile", errorDetails);
        }
      } catch (e) {
        _showError('An error occurred', e.toString());
      } finally {
         if (mounted) { // Check if widget is still mounted
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // Form is not valid, show a generic message or rely on field validators
       _showError("Validation Error", "Please fill all required fields correctly.");
    }
  }

  // ----- Helper methods for showing dialogs -----
  void _showError(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
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
        backgroundColor: Colors.green,
      ),
    );
  }
 // ----- End Helper methods -----


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create Your Farm Profile'),
        backgroundColor: AppColors.background,
        centerTitle: true,
         automaticallyImplyLeading: false, // Remove back button if desired after signup
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Please provide details about your farm.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // --- Farm Name, Location, Size (Text Fields) ---
                    TextFormField(
                      controller: _farmNameController,
                      decoration: _inputDecoration('Farm Name (e.g., Green Acres)'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter farm name'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _farmLocationController,
                      decoration: _inputDecoration(
                          'Farm Location (e.g., Kano, Nigeria)'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter farm location'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: _farmSizeController,
                      decoration:
                          _inputDecoration('Farm Size (e.g., 5 Hectares)'),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter farm size'
                          : null,
                    ),
                    const SizedBox(height: 25),

                    // --- Soil Type (Dropdown) ---
                     _buildSectionTitle('Soil Details'),
                     DropdownButtonFormField<String>(
                       value: _selectedSoilType, // Bind to state variable
                       decoration: _inputDecoration('Soil Type'),
                       hint: const Text('Select Soil Type'), // Placeholder
                       items: _soilTypes.map((String type) {
                         return DropdownMenuItem<String>(
                           value: type,
                           child: Text(type),
                         );
                       }).toList(),
                       onChanged: (value) {
                         setState(() {
                           _selectedSoilType = value;
                         });
                       },
                       validator: (value) =>
                           value == null ? 'Please select soil type' : null,
                       dropdownColor: AppColors.background, // Match background
                       style: const TextStyle(color: AppColors.grey),
                     ),
                     const SizedBox(height: 25),

                    // --- pH Value (Slider) ---
                    _buildSectionTitle('Soil pH Level'),
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
                    Slider(
                      value: _pHValue,
                      min: 3.0, // Adjusted practical min pH
                      max: 14.0, // Adjusted practical max pH
                      divisions: 70, // (10.0 - 3.0) * 10 = 70 divisions for 0.1 steps
                      activeColor: AppColors.secondary,
                      inactiveColor: AppColors.grey.withOpacity(0.5),
                       label: _pHValue.toStringAsFixed(1), // Show label on drag
                      onChanged: (value) {
                        setState(() {
                          _pHValue = value;
                        });
                      },
                    ),
                    const SizedBox(height: 25),


                     // --- Current Crop (Dropdown) ---
                    _buildSectionTitle('Crop Focus'),
                    DropdownButtonFormField<String>(
                      value: _selectedCurrentCrop,
                      decoration: _inputDecoration('Current Crop'),
                      hint: const Text('Select Current Crop'),
                      items: _cropTypes.map((String crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrentCrop = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select current crop' : null,
                       dropdownColor: AppColors.background,
                       style: const TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 15),


                    // --- Future Crop (Dropdown) ---
                    DropdownButtonFormField<String>(
                      value: _selectedFutureCrop,
                      decoration: _inputDecoration('Planned Future Crop'),
                       hint: const Text('Select Future Crop'),
                      items: _cropTypes.map((String crop) {
                        return DropdownMenuItem<String>(
                          value: crop,
                          child: Text(crop),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFutureCrop = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select future crop' : null,
                       dropdownColor: AppColors.background,
                       style: const TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 25),

                    // --- Irrigation System (Radio Buttons) ---
                    _buildSectionTitle('Irrigation System'),
                    // Using Wrap for better layout if needed
                     Column(
                         children: _irrigationOptions.map((option) => RadioListTile<String>(
                           title: Text(option, style: const TextStyle(color: AppColors.grey)),
                           value: option,
                           groupValue: _selectedIrrigation,
                           onChanged: (String? value) {
                             setState(() {
                               _selectedIrrigation = value!;
                             });
                           },
                           activeColor: AppColors.secondary,
                           contentPadding: EdgeInsets.zero, // Remove extra padding
                            visualDensity: VisualDensity.compact, // Make them denser
                         )).toList(),
                       ),
                    const SizedBox(height: 20),


                    // --- Location Button ---
                    ElevatedButton.icon(
                      icon: _isGettingLocation
                          ? const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.grey))
                          : const Icon(Icons.location_searching,
                              color: AppColors.grey),
                      label: Text(
                          _latitude == null
                              ? 'Get Current Location (Optional)'
                              : 'Location Acquired (${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)})',
                          style: const TextStyle(color: AppColors.grey)),
                      onPressed: _isGettingLocation ? null : _getCurrentLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder( // Added border radius
                            borderRadius: BorderRadius.circular(8),
                          ),
                      ),
                    ),
                    const SizedBox(height: 30),


                    // --- Save Button ---
                    ElevatedButton(
                      onPressed: _saveFarmProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                         shape: RoundedRectangleBorder( // Added border radius
                            borderRadius: BorderRadius.circular(8),
                          ),
                         textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text(
                        'Save Farm Profile & Continue',
                        style: TextStyle(color: AppColors.grey),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper for section titles
  Widget _buildSectionTitle(String title) {
     return Padding(
       padding: const EdgeInsets.only(bottom: 8.0),
       child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.grey, // Or AppColors.secondary
          ),
        ),
     );
   }


  // Helper for consistent input decoration
  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.7)),
      floatingLabelStyle: const TextStyle(color: AppColors.secondary),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.secondary),
         borderRadius: BorderRadius.all(Radius.circular(8)), // Added radius
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.secondary, width: 2.0),
         borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
         borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
         borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.secondary),
           borderRadius: BorderRadius.all(Radius.circular(8)),
       ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
       filled: true, // Optional: Add fill color
       fillColor: AppColors.primary.withOpacity(0.1), // Optional: Light fill
    );
  }
}