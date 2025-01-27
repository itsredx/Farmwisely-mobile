// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart'; // Add image_picker package

class Settings extends StatefulWidget {
  const Settings({super.key, required this.onPageChange});
  final Function(int) onPageChange;

  @override
  State<Settings> createState() => _SettingsState();
}

enum MeasurementUnit { metric, imperial }

class _SettingsState extends State<Settings> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _eMailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  bool _weatherAlerts = true;
  bool _cropGrowthUpdates = false;
  bool _farmTaskReminders = true;
  MeasurementUnit _selectedUnit = MeasurementUnit.metric;
  String? _profileImage;
  late ImageProvider _imageProvider;
  File? _imageFile;
  bool _isLoading = true;
  String? _token;

  @override
void initState() {
 super.initState();
 _loadToken();
}
Future<void> _loadToken() async {
   final prefs = await SharedPreferences.getInstance();
   final String? token = prefs.getString('token');
   if (token != null) {
     setState(() {
       _token = token;
        _loadProfileData();
     });
   }else{
     setState(() {
       _isLoading = false;
     });
   }
}

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _imageFile = File(pickedFile!.path);
      _imageProvider = FileImage(_imageFile!);
    });
  }



  // Method to save the data as JSON
  Future<void> _saveProfileData() async {
 setState(() {
       _isLoading = true;
     });
 try {
   Map<String, dynamic> profileData = {
     'name': _nameController.text,
     'email': _eMailController.text,
     'phoneNumber': _phoneNumberController.text,
     'measurementUnit': _selectedUnit.toString().split('.').last,
     'weatherAlerts': _weatherAlerts,
     'cropGrowthUpdates': _cropGrowthUpdates,
     'farmTaskReminders': _farmTaskReminders,
   };

   var request = http.MultipartRequest('PATCH', Uri.parse('http://your_backend_url/api/profile/'));
   request.headers['Authorization'] = 'Token $_token';
   request.fields.addAll({
       'name': _nameController.text,
       'email': _eMailController.text,
       'phoneNumber': _phoneNumberController.text,
       'measurementUnit': _selectedUnit.toString().split('.').last,
       'weatherAlerts': _weatherAlerts.toString(),
       'cropGrowthUpdates': _cropGrowthUpdates.toString(),
       'farmTaskReminders': _farmTaskReminders.toString(),
   });
   if (_imageFile != null) {
         request.files.add(await http.MultipartFile.fromPath('profileImage', _imageFile!.path));
   }
   var response = await request.send();
   if (response.statusCode == 200) {
     _showSuccess('Profile updated successfully');
    _loadProfileData();
   } else {
     final responseBody = await response.stream.bytesToString();
     _showError('Error saving profile data', responseBody);
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


Future<void> _loadProfileData() async {
 try {
   final response = await http.get(
     Uri.parse('http://your_backend_url/api/profile/'),
     headers: {
       'Authorization': 'Token $_token',
     },
   );

   if (response.statusCode == 200) {
     final decodedData = json.decode(response.body);
     setState(() {
       _nameController.text = decodedData['name'] ?? '';
       _eMailController.text = decodedData['email'] ?? '';
       _phoneNumberController.text = decodedData['phoneNumber'] ?? '';
       _selectedUnit = decodedData['measurementUnit'] == 'metric'
           ? MeasurementUnit.metric
           : MeasurementUnit.imperial;
       _weatherAlerts = decodedData['weatherAlerts'] ?? true;
       _cropGrowthUpdates = decodedData['cropGrowthUpdates'] ?? false;
       _farmTaskReminders = decodedData['farmTaskReminders'] ?? true;
       if (decodedData['profileImage'] != null) {
           String imageUrl = 'https://your_server_url/' + decodedData['profileImage'];
           _profileImage = imageUrl;
         _imageProvider = NetworkImage(imageUrl);

       }else{
           _imageProvider = const AssetImage('assets/images/profile.jpg');
       }
        _isLoading = false;
     });
   } else {
     _showError('Error loading profile data from the server', response.body);
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
              'Settings and Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Manage your profile',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await _saveProfileData();
              // Debug Log
              // Show a confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Profile data saved successfully!',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.save),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity, // Expand to fill available width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                ),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 26,
                    ),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: _imageProvider,
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () async {
                                // Debug log
                                await _pickImageFromGallery(); // added await for async function
                                // Debug log
                              },
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    const SizedBox(
                      height: 26,
                    ),
                    // Text Fields start here
                    _buildTextFieldRow(
                      labelText: 'Name',
                      hintText: 'Ahmad Muhammad',
                      controller: _nameController,
                    ),
                    _buildTextFieldRow(
                      labelText: 'Email',
                      hintText: 'youremail@example.com',
                      controller: _eMailController,
                    ),
                    _buildTextFieldRow(
                      labelText: 'Phone No.',
                      hintText: '+911234567890',
                      controller: _phoneNumberController,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity, // Expand to fill available width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification Prefrences',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Turn notification on or off',
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                      ),
                      _buildSwitchRow(
                          text: 'Weather Alerts',
                          value: _weatherAlerts,
                          onChanged: (value) =>
                              setState(() => _weatherAlerts = value)),
                      _buildSwitchRow(
                          text: 'Crop Growth Updates',
                          value: _cropGrowthUpdates,
                          onChanged: (value) =>
                              setState(() => _cropGrowthUpdates = value)),
                      _buildSwitchRow(
                          text: 'Reminders For farm Task',
                          value: _farmTaskReminders,
                          onChanged: (value) =>
                              setState(() => _farmTaskReminders = value)),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Container(
                width: double.infinity, // Expand to fill available width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Units of Measurement',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Select measurement units',
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                      ),
                      RadioListTile<MeasurementUnit>(
                        title: const Text(
                          'Metric (kg, heaters, °C)',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        value: MeasurementUnit.metric,
                        groupValue: _selectedUnit,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                        activeColor: AppColors.secondary,
                      ),
                      RadioListTile<MeasurementUnit>(
                        title: const Text(
                          'Imperial (lbs,  acres, °F)',
                          style: TextStyle(color: AppColors.grey),
                        ),
                        value: MeasurementUnit.imperial,
                        groupValue: _selectedUnit,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnit = value!;
                          });
                        },
                        activeColor: AppColors.secondary,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Information',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Farm related settings are in the My Farm Page',
                      style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                          fontStyle: FontStyle.italic),
                    ),
                  ]),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _skip, // Skip functionality
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: AppColors.grey,
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(
                    width: 50.0,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Debug log
                      await _saveProfileData();
                      // Show a confirmation message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile data saved successfully!',
                          ),
                        ),
                      );
                    }, // Save functionality
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
        ),
      ),
    );
  }

  void _skip() {
    widget.onPageChange(0);
  }

  Widget _buildTextFieldRow(
      {required String labelText,
      required String hintText,
      TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              labelText,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: AppColors.secondary, width: 0.5))),
              child: CupertinoTextField(
                controller: controller,
                placeholder: hintText,
                placeholderStyle: const TextStyle(
                  color: AppColors.grey,
                ),
                style: const TextStyle(
                  color: AppColors.grey,
                ),
                decoration: const BoxDecoration(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 16,
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.secondary,
            thumbColor: AppColors.grey,
            inactiveTrackColor: const Color.fromARGB(80, 33, 33, 33),
          )
        ],
      ),
    );
  }
}
