// ignore_for_file: unused_element, avoid_print

import 'dart:convert';
import 'package:farmwisely/utils/colors.dart';
import 'package:farmwisely/widgets/crop_card.dart';
// Import the new alternative crop card
import 'package:farmwisely/widgets/alternative_crop_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Convert to StatefulWidget
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  bool _isLoading = true;
  String? _token;
  int? _farmId;
  Map<String, dynamic>? _recommendationsData; // To store API response
  String? _errorMessage; // To store error messages
  Map<String, dynamic>? _farmProfileData; // To store basic farm profile data

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? farmId = prefs.getInt('farmId');
    final String? farmDataString = prefs.getString('farmData'); // Load cached farm data

    if (token != null && farmId != null) {
      if (!mounted) return;
      setState(() {
        _token = token;
        _farmId = farmId;
         // Try to load cached farm profile data for the overview
         if (farmDataString != null) {
           try {
             _farmProfileData = json.decode(farmDataString);
           } catch (e) {
             print("Error decoding cached farm data: $e");
              _farmProfileData = null; // Reset if decoding fails
           }
         }
      });
      await _fetchRecommendations(); // Fetch recommendations
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Authentication token or Farm ID not found. Please login or set up your farm.";
      });
    }
  }

  Future<void> _fetchRecommendations({String? userNotes}) async {
    if (_token == null || _farmId == null) {
      setState(() {
        _errorMessage = "Missing token or Farm ID.";
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
      // _recommendationsData = null; // Optionally clear previous data
    });

    try {
      // Construct URL, adding notes if provided
       String apiUrl = 'https://devred.pythonanywhere.com/api/recommendations/$_farmId/';
       if (userNotes != null && userNotes.isNotEmpty) {
         apiUrl += '?notes=${Uri.encodeComponent(userNotes)}';
       }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Token $_token',
        },
      );

      if (!mounted) return; // Check after await

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          _recommendationsData = decodedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load recommendations (Status: ${response.statusCode}): ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Helper to show errors
   void _showErrorDialog(String message) {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text('Error'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // ... (AppBar remains mostly the same) ...
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
         title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Crop Recommendations', // Corrected typo
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Personalized suggestions for your farm', // Corrected typo
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Recommendations',
            onPressed: _isLoading ? null : () => _fetchRecommendations(), // Call fetch method
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: _buildBody(), // Use a helper method for the body
    );
  }

   Widget _buildBody() {
     if (_isLoading) {
       return const Center(child: CircularProgressIndicator());
     }

     if (_errorMessage != null) {
       // Optionally show the error dialog immediately
       // WidgetsBinding.instance.addPostFrameCallback((_) {
       //    _showErrorDialog(_errorMessage!);
       // });
       return Center(
         child: Padding(
           padding: const EdgeInsets.all(20.0),
           child: Text(
             'Error loading recommendations:\n$_errorMessage',
             style: const TextStyle(color: Colors.redAccent, fontSize: 16),
             textAlign: TextAlign.center,
           ),
         ),
       );
     }

     if (_recommendationsData == null) {
       return const Center(
         child: Text(
           'No recommendations available.',
           style: TextStyle(color: AppColors.grey, fontSize: 16),
         ),
       );
     }

     // --- Data is loaded, build the dynamic UI ---
     final List<dynamic> mainRecs = _recommendationsData!['Main Crop Recommendations'] ?? [];
     final List<dynamic> altRecs = _recommendationsData!['Alternative Crop Recommendations'] ?? [];

     return SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Farm Profile Overview (using cached data if available)
             _buildFarmOverview(),
             const SizedBox(height: 20),

             // --- Recommended Crops Section ---
             const Text(
               'Recommended Crops',
               style: TextStyle(
                 color: AppColors.grey,
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
               ),
             ),
             const SizedBox(height: 10),
             if (mainRecs.isEmpty)
               const Text('No main crop recommendations found.', style: TextStyle(color: AppColors.grey))
             else
               // Use ListView.builder for potentially long lists
               ListView.separated(
                 physics: const NeverScrollableScrollPhysics(), // Disable inner scrolling
                 shrinkWrap: true,
                 itemCount: mainRecs.length,
                 itemBuilder: (context, index) {
                   final item = mainRecs[index];
                   return CropCard(
                     // Safely access map keys, provide defaults or handle nulls
                     cropName: item['Crop Name'] ?? 'N/A',
                     sustainabilityRating: item['Sustainability Rating'] ?? 'N/A',
                     benefits: item['Benefits'] ?? 'N/A',
                     tips: item['Tips'] ?? 'N/A',
                     description: item['Description'] ?? 'N/A',
                   );
                 },
                 separatorBuilder: (context, index) => const SizedBox(height: 12),
               ),

              // --- Action Buttons (Optional) ---
              // You might want to add these back later based on app features
              // _buildActionButtons(),
             const SizedBox(height: 20),


              // --- Alternative Crops Section ---
             const Text(
               'Alternative Crops',
               style: TextStyle(
                 color: AppColors.grey,
                 fontSize: 16,
                 fontWeight: FontWeight.w500,
               ),
             ),
             const SizedBox(height: 10),
              if (altRecs.isEmpty)
               const Text('No alternative crop recommendations found.', style: TextStyle(color: AppColors.grey))
             else
               ListView.separated(
                 physics: const NeverScrollableScrollPhysics(),
                 shrinkWrap: true,
                 itemCount: altRecs.length,
                 itemBuilder: (context, index) {
                   final item = altRecs[index];
                   return AlternativeCropCard(
                     cropName: item['Crop Name'] ?? 'N/A',
                     sustainabilityRating: item['Sustainability Rating'] ?? 'N/A',
                     reason: item['Reason for Consideration'] ?? 'N/A',
                   );
                 },
                 separatorBuilder: (context, index) => const SizedBox(height: 12),
               ),

             // --- More Action Buttons (Optional) ---
             // _buildMoreActionButtons(),
              const SizedBox(height: 20), // Bottom padding
           ],
         ),
       ),
     );
   }


   // Helper to build the farm overview section (using cached data)
   Widget _buildFarmOverview() {
     if (_farmProfileData == null) {
       return const SizedBox.shrink(); // Return empty if no cached data
     }
     // Extract data safely with null checks and defaults
     String location = _farmProfileData!['farmLocation'] ?? 'N/A';
     String soil = _farmProfileData!['soilType'] ?? 'N/A';
     String ph = (_farmProfileData!['pHValue'] != null) ? _farmProfileData!['pHValue'].toString() : 'N/A';
     String size = _farmProfileData!['farmSize'] ?? 'N/A';
      // You might need to fetch weather data separately if you want to display it here

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text(
           'Farm Profile Overview',
           style: TextStyle(
             color: AppColors.grey,
             fontSize: 16,
             fontWeight: FontWeight.w500,
           ),
         ),
         const SizedBox(height: 10),
         _buildOverviewRow('Farm Location', location),
         _buildOverviewRow('Soil Type', soil),
         _buildOverviewRow('pH Level', ph),
         _buildOverviewRow('Size', size),
         // Add more rows if needed (e.g., for weather)
       ],
     );
   }

    Widget _buildOverviewRow(String label, String value) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 3.0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(
             label,
             style: const TextStyle(
               color: AppColors.grey,
               fontSize: 14,
               fontWeight: FontWeight.w500,
             ),
           ),
           Text(
             value,
             style: const TextStyle(
                 color: AppColors.grey,
                 fontSize: 14,
                 fontStyle: FontStyle.italic),
           ),
         ],
       ),
     );
   }

   // Placeholder for action buttons if you re-add them

   Widget _buildActionButtons() {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 16.0),
       child: Column(
         children: [
           // Example Button
           SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () { /* TODO: Implement planning */ },
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 10),
                 backgroundColor: AppColors.secondary,
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               child: const Text(
                 'Start Planning Crop Rotation',
                 style: TextStyle(
                     color: AppColors.grey,
                     fontSize: 16,
                     fontWeight: FontWeight.bold),
               ),
             ),
           ),
            const SizedBox(height: 10),
             SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () { /* TODO: Implement download */ },
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 10),
                 backgroundColor: AppColors.secondary,
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               child: const Text(
                 'Download Recommendations',
                 style: TextStyle(
                     color: AppColors.grey,
                     fontSize: 16,
                     fontWeight: FontWeight.bold),
               ),
             ),
           ),
         ],
       ),
     );
   }


    Widget _buildMoreActionButtons() {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () => _fetchRecommendations(), // Generate new = refresh
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 10),
                 backgroundColor: AppColors.secondary,
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               child: const Text(
                 'Generate New Recommendations',
                 style: TextStyle(
                     color: AppColors.grey,
                     fontSize: 16,
                     fontWeight: FontWeight.bold),
               ),
             ),
           ),
             const SizedBox(height: 10),
            SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: () { /* TODO: Navigate to farm edit page */ },
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 10),
                 backgroundColor: AppColors.secondary,
                 elevation: 0,
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               child: const Text(
                 'Adjust Farm Details',
                 style: TextStyle(
                     color: AppColors.grey,
                     fontSize: 16,
                     fontWeight: FontWeight.bold),
               ),
             ),
           ),
          ],
        ),
      );
    }


} // End of _RecommendationsScreenState