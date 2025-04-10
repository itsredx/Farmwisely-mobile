// ignore_for_file: no_leading_underscores_for_local_identifiers, prefer_final_fields, use_build_context_synchronously, unused_field, unused_local_variable

import 'dart:convert';
import 'dart:io';
import 'package:farmwisely/main.dart'; // Import MyApp if needed for type reference
import 'package:farmwisely/screens/login.dart'; // Import LoginScreen for navigation
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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
  String? _profileImageUrlFromServer; // Store the URL from server
  late ImageProvider _imageProvider =
      const AssetImage('assets/images/profile.jpg'); // Default image
  File? _imageFile; // For newly picked image
  bool _isLoading = true;
  String? _token;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

   @override
   void dispose() {
     _nameController.dispose();
     _eMailController.dispose();
     _phoneNumberController.dispose();
     super.dispose();
   }


  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? userId = prefs.getInt('userId');
    if (token != null && userId != null) {
       // Use mounted check before setState in async gaps
       if (!mounted) return;
      setState(() {
        _token = token;
        _userId = userId;
        // Don't set _isLoading = false here, let _loadProfileData handle it
      });
       await _loadProfileData(); // Await loading profile data
    } else {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        // Handle case where user isn't logged in - maybe navigate back?
        // e.g., Navigator.of(context).pop(); or navigate to Login
      });
    }
  }

  Future<void> _loadProfileData() async {
    // Ensure token is loaded before proceeding
    if (_token == null) {
       if (mounted) {
         setState(() => _isLoading = false);
         _showError("Authentication Error", "Token not found.");
       }
      return;
    }

     // Start loading indicator specifically for this data fetch
     if (mounted) setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://devred.pythonanywhere.com/api/profile/'),
        headers: {
          'Authorization': 'Token $_token',
        },
      );

      if (!mounted) return; // Check again after await

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          _nameController.text = decodedData['name'] ?? '';
          _eMailController.text = decodedData['email'] ?? ''; // Email loaded here
          _phoneNumberController.text = decodedData['phoneNumber'] ?? '';
          _selectedUnit = (decodedData['measurementUnit'] ?? 'metric') == 'metric'
              ? MeasurementUnit.metric
              : MeasurementUnit.imperial;
          _weatherAlerts = decodedData['weatherAlerts'] ?? true;
          _cropGrowthUpdates = decodedData['cropGrowthUpdates'] ?? false;
          _farmTaskReminders = decodedData['farmTaskReminders'] ?? true;

          _profileImageUrlFromServer = decodedData['profileImage']; // Store URL
          if (_profileImageUrlFromServer != null && _profileImageUrlFromServer!.isNotEmpty) {
            // Ensure URL is absolute
            String imageUrl = _profileImageUrlFromServer!;
            if (!imageUrl.startsWith('http')) {
               imageUrl = 'https://devred.pythonanywhere.com' + imageUrl;
            }
             _imageProvider = NetworkImage(imageUrl);
          } else {
            // Keep the default if no image from server
             _imageProvider = const AssetImage('assets/images/profile.jpg');
          }
        });
      } else {
        _showError('Error loading profile data', response.body);
      }
    } catch (e) {
      _showError('An error occurred during profile load', e.toString());
    } finally {
      // Ensure loading indicator stops regardless of outcome
       if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
       final pickedFile = await ImagePicker().pickImage(
         source: ImageSource.gallery,
         imageQuality: 80, // Optionally compress image
       );
       if (pickedFile != null) {
          if (!mounted) return;
         setState(() {
           _imageFile = File(pickedFile.path);
           _imageProvider = FileImage(_imageFile!); // Update preview immediately
         });
       }
     } catch (e) {
        if (!mounted) return;
       _showError("Image Picker Error", e.toString());
     }
  }

  Future<void> _saveProfileData() async {
     if (_token == null) {
       _showError("Authentication Error", "Token not found.");
       return;
     }

    setState(() {
      _isLoading = true;
    });
    try {
      var request = http.MultipartRequest(
          'PATCH', Uri.parse('https://devred.pythonanywhere.com/api/profile/'));
      request.headers['Authorization'] = 'Token $_token';

      // Add text fields
       request.fields.addAll({
         'name': _nameController.text,
         'email': _eMailController.text, // Save potentially edited email
         'phoneNumber': _phoneNumberController.text,
         'measurementUnit': _selectedUnit.toString().split('.').last,
         'weatherAlerts': _weatherAlerts.toString(),
         'cropGrowthUpdates': _cropGrowthUpdates.toString(),
         'farmTaskReminders': _farmTaskReminders.toString(),
       });


      // Add image file ONLY if a new one was picked
      if (_imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('profileImage', _imageFile!.path));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

       if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) { // PATCH might return 200
        _showSuccess('Profile updated successfully');
         _imageFile = null; // Clear picked file after successful upload
         await _loadProfileData(); // Reload data to show saved state (including new image URL if backend provides it)
      } else {
        _showError('Error saving profile data', 'Status Code: ${response.statusCode}\nResponse: $responseBody');
      }
    } catch (e) {
       if (!mounted) return;
      _showError('An error occurred during save', e.toString());
    } finally {
       if (mounted) {
         setState(() {
           _isLoading = false;
         });
       }
    }
  }

  // --- Sign Out Logic ---
  Future<void> _showSignOutConfirmationDialog() async {
     if (!mounted) return;
     showDialog<bool>( // Specify the return type for clarity
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text('Sign Out'),
           content: const Text('Are you sure you want to sign out?'),
           actions: <Widget>[
             TextButton(
               child: const Text('Cancel'),
               onPressed: () {
                 Navigator.of(context).pop(false); // Return false on cancel
               },
             ),
             TextButton(
               style: TextButton.styleFrom(foregroundColor: Colors.red),
               child: const Text('Sign Out'),
               onPressed: () {
                  Navigator.of(context).pop(true); // Return true on confirmation
               },
             ),
           ],
         );
       },
     ).then((confirmed) { // Handle the result of the dialog
        if (confirmed == true) {
           _signOut(); // Proceed with sign out only if confirmed
        }
     });
   }

  Future<void> _signOut() async {
     if (!mounted) return; // Check mount status before async operation

     setState(() {
       _isLoading = true; // Show loading indicator during sign out
     });

     try {
       final prefs = await SharedPreferences.getInstance();
       await prefs.remove('token');
       await prefs.remove('userId');
       await prefs.remove('farmId'); // Also clear farmId if stored
       await prefs.remove('farmData'); // Also clear cached farmData if stored
       // Add any other keys specific to the logged-in user

       if (!mounted) return; // Check again after await

       // Navigate to Login Screen and remove all previous routes
       Navigator.of(context).pushAndRemoveUntil(
         MaterialPageRoute(builder: (context) => const LoginScreen()),
         (Route<dynamic> route) => false, // This predicate removes all routes
       );
     } catch (e) {
        if (!mounted) return;
        _showError("Sign Out Error", "Could not clear preferences: ${e.toString()}");
         setState(() {
           _isLoading = false; // Stop loading indicator on error
         });
     }
     // No need for finally block to set isLoading false here,
     // as successful navigation removes this widget tree.
   }
   // --- End Sign Out Logic ---


  // --- Helper methods for showing dialogs/snackbar ---
   void _showError(String message, String details) {
     if (!mounted) return; // Check mount status
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
     if (!mounted) return;
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(
         content: Text(message),
         duration: Duration(seconds: 2),
         backgroundColor: Colors.green, // Added success color
       ),
     );
   }
  // --- End Helper methods ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onPageChange(0); // Navigate back using the provided callback
          },
        ),
        title: const Column(
          // ... (AppBar title remains the same)
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
           // Keep Save button if needed, or remove if save is only via bottom button
          // IconButton(
          //   onPressed: _saveProfileData,
          //   tooltip: 'Save Profile',
          //   icon: const Icon(Icons.save),
          // ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Profile Section ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20.0), // Added padding
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.primary,
                      ),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.bottomRight, // Align edit button
                            children: [
                              CircleAvatar(
                                radius: 60, // Slightly smaller radius
                                backgroundImage: _imageProvider,
                                backgroundColor: AppColors.secondary.withOpacity(0.2), // Placeholder bg
                              ),
                              Material( // Wrap IconButton for InkWell effect
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: _pickImageFromGallery,
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: AppColors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                           const SizedBox(height: 20),
                           // Text Fields for Name, Email, Phone
                           _buildTextFieldRow(
                             labelText: 'Name',
                             hintText: 'Your Name',
                             controller: _nameController,
                           ),
                            _buildTextFieldRow(
                             labelText: 'Email',
                             hintText: 'your.email@example.com',
                             controller: _eMailController,
                             keyboardType: TextInputType.emailAddress,
                              readOnly: true, // Make Email read-only if it shouldn't be edited
                           ),
                            _buildTextFieldRow(
                             labelText: 'Phone No.',
                             hintText: '+1234567890',
                             controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                           ),
                           const SizedBox(height: 10), // Reduced bottom padding
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Notification Preferences ---
                     Container(
                       // ... (Notification container remains the same)
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
                                'Notification Preferences',
                                style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Text(
                                'Turn notifications on or off',
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
                                  text: 'Farm Task Reminders',
                                  value: _farmTaskReminders,
                                  onChanged: (value) =>
                                      setState(() => _farmTaskReminders = value)),
                            ],
                          ),
                        ),
                    ),
                    const SizedBox(height: 16),

                    // --- Units of Measurement ---
                    Container(
                      // ... (Units container remains the same)
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
                                  'Metric (kg, hectares, °C)', // Corrected typo
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
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                              RadioListTile<MeasurementUnit>(
                                title: const Text(
                                  'Imperial (lbs, acres, °F)',
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
                                contentPadding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                    ),
                    const SizedBox(height: 16),

                    // --- Farm Information Link ---
                    Container(
                       width: double.infinity,
                       padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary,
                        ),
                      child: const Column(
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
                              'Farm related settings are in the My Farm Page.',
                              style: TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 24),

                     // --- Save Button ---
                     Center( // Center the save button
                       child: ElevatedButton.icon(
                          icon: const Icon(Icons.save, color: AppColors.grey),
                          label: const Text('Save Changes', style: TextStyle(color: AppColors.grey)),
                          onPressed: _saveProfileData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                             shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                          ),
                        ),
                     ),
                      const SizedBox(height: 20), // Spacing before sign out

                     // --- Sign Out Button ---
                     Center( // Center the sign out button
                       child: ElevatedButton.icon(
                         icon: const Icon(Icons.logout, color: Colors.white),
                         label: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                         onPressed: _showSignOutConfirmationDialog, // Trigger confirmation dialog
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.redAccent, // Distinct color for sign out
                           padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                         ),
                       ),
                     ),
                     const SizedBox(height: 20), // Bottom padding

                  ],
                ),
              ),
            ),
    );
  }

   // --- Build Helper Widgets ---
  Widget _buildTextFieldRow({
    required String labelText,
    required String hintText,
    TextEditingController? controller,
     TextInputType? keyboardType,
     bool readOnly = false, // Added readOnly option
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically
        children: [
          SizedBox(
            width: 90, // Adjusted width
            child: Text(
              labelText,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 15, // Slightly smaller
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10), // Added spacing
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: hintText,
              placeholderStyle: TextStyle(
                color: AppColors.grey.withOpacity(0.6), // Lighter placeholder
              ),
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 15,
              ),
              decoration: BoxDecoration( // Use BoxDecoration for border control
                  border: Border(
                      bottom: BorderSide(
                           color: readOnly ? Colors.transparent : AppColors.secondary, // Hide border if readOnly
                           width: 0.8)
                      )
                  ),
               padding: const EdgeInsets.symmetric(vertical: 8.0), // Added padding
               keyboardType: keyboardType,
               readOnly: readOnly, // Apply readOnly property
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
      padding: const EdgeInsets.symmetric(vertical: 4.0), // Reduced vertical padding
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded( // Allow text to wrap if needed
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 15, // Slightly smaller
              ),
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.secondary,
            // Optional: Customize thumb color more
            thumbColor: value ? AppColors.grey : Colors.grey[700],
             trackColor: Colors.grey.withOpacity(0.3), // Customize inactive track
          )
        ],
      ),
    );
  }
  // --- End Build Helper Widgets ---

} // End of _SettingsState