// set_profile_details_screen.dart
import 'dart:io';
import 'package:farmwisely/screens/auth/create_farm_profile_screen.dart'; // Next screen
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class SetProfileDetailsScreen extends StatefulWidget {
  final String userEmail; // Receive email from signup

  const SetProfileDetailsScreen({
    super.key,
    required this.userEmail,
  });

  @override
  State<SetProfileDetailsScreen> createState() => _SetProfileDetailsScreenState();
}

class _SetProfileDetailsScreenState extends State<SetProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _eMailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  late ImageProvider _imageProvider =
      const AssetImage('assets/images/profile.jpg'); // Default image
  File? _imageFile; // For newly picked image
  bool _isLoading = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _eMailController.text = widget.userEmail; // Pre-fill email
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
    final String? loadedToken = prefs.getString('token');
    if (loadedToken != null) {
      if (!mounted) return;
      setState(() {
        _token = loadedToken;
      });
    } else {
       if (!mounted) return;
      // Handle error: If token is somehow null, maybe pop back to login?
      _showError('Authentication Error',
          'Could not load user token. Please login again.');
      // Consider Navigator.pop(context); or navigating back to login
       Navigator.of(context).pop();
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

  Future<void> _saveProfileDetailsAndContinue() async {
    if (_token == null) {
      _showError("Authentication Error", "Token not found.");
      return;
    }

    // Optional: Add validation using the _formKey if needed for name/phone
    // if (!_formKey.currentState!.validate()) {
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });

    try {
      var request = http.MultipartRequest(
          'PATCH', Uri.parse('https://devred.pythonanywhere.com/api/profile/'));
      request.headers['Authorization'] = 'Token $_token';

      // Add text fields (only send if they have content, or send empty strings)
      // Check backend: Does it require these fields or are they optional on PATCH?
      request.fields['name'] = _nameController.text;
      request.fields['phoneNumber'] = _phoneNumberController.text;
      request.fields['email'] = _eMailController.text;
      // We usually DON'T PATCH the email here, as it's tied to the user account itself.
      // The backend should already associate this profile update with the logged-in user via the token.

      // Add image file ONLY if a new one was picked
      if (_imageFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('profileImage', _imageFile!.path));
      }

      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
         _showSuccess('Profile details saved!');
         // Navigate to the next step: Create Farm Profile
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(
             builder: (context) => const CreateFarmProfileScreen(),
           ),
         );
      } else {
         _showError('Failed to Save Profile', 'Status Code: ${response.statusCode}\nResponse: $responseBody');
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

  // --- Helper methods for showing dialogs/snackbar ---
  void _showError(String message, String details) {
    if (!mounted) return;
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
        backgroundColor: Colors.green,
      ),
    );
  }
  // --- End Helper methods ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        backgroundColor: AppColors.background,
        centerTitle: true,
        automaticallyImplyLeading: false, // Prevent going back to signup
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                     const Text(
                      "Let's add some details to your profile.",
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                      textAlign: TextAlign.center,
                    ),
                     const SizedBox(height: 30),

                      // --- Profile Picture ---
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 70,
                              backgroundImage: _imageProvider,
                              backgroundColor: AppColors.primary.withOpacity(0.5),
                            ),
                             Material( // Wrap IconButton for InkWell effect
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(25),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(25),
                                  onTap: _pickImageFromGallery,
                                  child: const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(
                                      Icons.camera_alt, // Camera icon is more fitting
                                      color: AppColors.grey,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Text Fields ---
                       _buildProfileTextField(
                         controller: _nameController,
                         labelText: 'Full Name (Optional)',
                         hintText: 'Enter your full name',
                         icon: Icons.person_outline,
                       ),
                        const SizedBox(height: 20),
                       _buildProfileTextField(
                         controller: _eMailController,
                         labelText: 'Email',
                         hintText: '', // Already pre-filled
                         icon: Icons.email_outlined,
                         readOnly: true, // Make email read-only
                       ),
                       const SizedBox(height: 20),
                       _buildProfileTextField(
                         controller: _phoneNumberController,
                         labelText: 'Phone Number (Optional)',
                         hintText: 'Enter your phone number',
                         icon: Icons.phone_outlined,
                         keyboardType: TextInputType.phone,
                       ),
                       const SizedBox(height: 40),


                      // --- Save Button ---
                      ElevatedButton(
                         onPressed: _saveProfileDetailsAndContinue,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.secondary,
                           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(8),
                             ),
                            textStyle: const TextStyle(fontSize: 16),
                         ),
                         child: const Text(
                           'Save & Continue to Farm Setup',
                           style: TextStyle(color: AppColors.grey),
                         ),
                       ),
                        const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper Widget for TextFields on this page
  Widget _buildProfileTextField({
     required TextEditingController controller,
     required String labelText,
     required String hintText,
     required IconData icon,
     bool readOnly = false,
     TextInputType? keyboardType,
  }) {
    return TextFormField( // Use TextFormField for potential validation
       controller: controller,
       readOnly: readOnly,
       keyboardType: keyboardType,
       style: const TextStyle(color: AppColors.grey),
       decoration: InputDecoration(
         labelText: labelText,
         hintText: hintText,
          prefixIcon: Icon(icon, color: AppColors.secondary.withOpacity(0.8)),
         floatingLabelStyle: const TextStyle(color: AppColors.secondary),
         hintStyle: TextStyle(color: AppColors.grey.withOpacity(0.6)),
          filled: true,
          fillColor: AppColors.primary.withOpacity(0.1),
         enabledBorder: OutlineInputBorder(
           borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.5)),
           borderRadius: BorderRadius.circular(8),
         ),
         focusedBorder: OutlineInputBorder(
           borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
           borderRadius: BorderRadius.circular(8),
         ),
          // Add error border if using validation
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
       ),
       // validator: (value) { // Example validator
       //   if (!readOnly && (value == null || value.isEmpty)) {
       //     return 'Please enter $labelText';
       //   }
       //   return null;
       // },
     );
  }

}