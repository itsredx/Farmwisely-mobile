import 'dart:convert'; // For json decoding
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For accessing stored data
import 'package:http/http.dart' as http; // For making API calls
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import '../widgets/weather_card.dart';
//import '../widgets/custom_card.dart';
import '../widgets/info_card.dart';
import '../utils/colors.dart'; // Assuming your colors are here

// Convert to StatefulWidget
class Home extends StatefulWidget {
  const Home({super.key, required this.onPageChange});
  final Function(int) onPageChange;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // State variables
  bool _isLoadingWeather = true; // Separate loading state for weather card
  String? _weatherErrorMessage;
  Map<String, dynamic>? _currentWeatherConditions;
  String? _weatherDisplayLocation; // Renamed for clarity
  String? _token;
  double? _latitude; // Changed to double for geocoding
  double? _longitude; // Changed to double for geocoding

  @override
  void initState() {
    super.initState();
    _loadPrerequisitesAndFetchWeather(); // Load data when the widget initializes
  }

  // --- Data Loading Logic ---
  Future<void> _loadPrerequisitesAndFetchWeather() async {
    if (!mounted) return;
    setState(() => _isLoadingWeather = true); // Start loading weather

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? farmDataString = prefs.getString('farmData');
    double? lat;
    double? lon;

    // Extract Lat/Lon from cached farm data
    if (farmDataString != null) {
      try {
        final Map<String, dynamic> farmData = json.decode(farmDataString);
        // Try to parse lat/lon as double
        lat = (farmData['latitude'] is num) ? (farmData['latitude'] as num).toDouble() : double.tryParse(farmData['latitude']?.toString() ?? '');
        lon = (farmData['longitude'] is num) ? (farmData['longitude'] as num).toDouble() : double.tryParse(farmData['longitude']?.toString() ?? '');
      } catch (e) {
        print("Home - Error decoding farm data: $e");
        // Don't set error message yet, let fetch handle it if lat/lon are null
      }
    }

    if (token != null && lat != null && lon != null) {
      if (!mounted) return;
      setState(() {
        _token = token;
        _latitude = lat;
        _longitude = lon;
      });
      await Future.wait([
        _fetchHomeWeatherData(),
        _fetchLocationName(), // Fetch location name using geocoding
      ]); // Fetch weather data
    } else {
      if (!mounted) return;
      setState(() {
        _isLoadingWeather = false;
        _weatherErrorMessage = "Farm location needed for weather."; // More specific error
      });
    }
    if (mounted && _isLoadingWeather) {
       setState(() => _isLoadingWeather = false);
     }
  }

  Future<void> _fetchHomeWeatherData() async {
    // Ensure prerequisites are loaded
    if (_token == null || _latitude == null || _longitude == null) {
       if (mounted) {
          setState(() {
            _weatherErrorMessage = "Cannot fetch weather: Missing token or location.";
            _isLoadingWeather = false;
          });
       }
      return;
    }

    if (!mounted) return;
    setState(() {
      _isLoadingWeather = true; // Show loading specifically for weather fetch
      _weatherErrorMessage = null;
    });

    try {
      final String apiUrl = 'https://devred.pythonanywhere.com/api/weather/$_latitude/$_longitude/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Token $_token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          // Store only necessary parts for the home card
          _currentWeatherConditions = decodedData['currentConditions'];
// Get first part of address (e.g., city)
          _isLoadingWeather = false;
        });
      } else {
        setState(() {
          _weatherErrorMessage = "Weather unavailable (${response.statusCode})";
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _weatherErrorMessage = "Weather network error"; // Simpler error for home
        _isLoadingWeather = false;
      });
       print("Home - Weather fetch error: $e"); // Log full error
    }
  }
  // --- New function for Reverse Geocoding ---
  Future<void> _fetchLocationName() async {
     if (_latitude == null || _longitude == null) return;

     try {
       // Use geocoding package
       List<Placemark> placemarks = await placemarkFromCoordinates(
         _latitude!,
         _longitude!,
         // localeIdentifier: "en_US" // Optional: Specify locale
       );

       if (!mounted) return;

       if (placemarks.isNotEmpty) {
         Placemark place = placemarks[0];
         // Construct a display name (customize as needed)
         String displayName = "${place.locality ?? place.subAdministrativeArea ?? ''}${place.locality != null && place.administrativeArea != null ? ', ' : ''}${place.administrativeArea ?? ''}";
         if (displayName.trim().isEmpty) {
           displayName = place.name ?? 'Nearby Location'; // Fallback
         }

         setState(() {
           _weatherDisplayLocation = displayName.trim();
         });
       } else {
          setState(() {
           _weatherDisplayLocation = "Unknown Location";
         });
       }
     } catch (e) {
       if (!mounted) return;
       print("Home - Geocoding error: $e");
        setState(() {
         _weatherDisplayLocation = "Location N/A"; // Show specific geocoding error
         // Optionally set _weatherErrorMessage too if desired
         // _weatherErrorMessage = "Could not get location name";
       });
     }
  }
  // --- End Geocoding Function ---
  // --- End Data Loading Logic ---

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // --- Dynamic Weather Card ---
            _buildWeatherSection(), // Use a helper to build this section
            // --- End Dynamic Weather Card ---

            const SizedBox(height: 16),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InfoCard(
                        image: 'assets/images/my_farm.jpg',
                        title: 'My Farm',
                        subtitle: 'Manage your farm effortlessly.',
                        onPressed: () {
                          widget.onPageChange(1); // Use widget.onPageChange
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InfoCard(
                        image: 'assets/images/recommendations.jpg',
                        title: 'Recommendations',
                        subtitle: 'Personalized suggestions for your farm.',
                        onPressed: () {
                          Navigator.pushNamed(context, '/recommendations');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  // ... other InfoCard rows remain the same ...
                   mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InfoCard(
                        image: 'assets/images/chat.jpg',
                        title: 'Chat',
                        subtitle: 'Connect and get expert advice.',
                        onPressed: () {
                          Navigator.pushNamed(context, '/chat');
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: InfoCard(
                        image: 'assets/images/weather_forecast.jpg',
                        title: 'Weather Forecast', // Corrected typo
                        subtitle:
                            'Stay updated with the latest weather trends.',
                        onPressed: () {
                          Navigator.pushNamed(context, '/weather');
                        },
                      ),
                    ),
                  ],
                ),
                 const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InfoCard(
                        image: 'assets/images/help.jpg',
                        title: 'Help',
                        subtitle: 'Get assistance whenever you need it.',
                        onPressed: () {
                          Navigator.pushNamed(context, '/help');
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: InfoCard(
                        image: 'assets/images/analytics.jpg',
                        title: 'Analytics',
                        subtitle: 'Track and analyze your farm\'s performance.',
                        onPressed: () {
                          widget.onPageChange(2); // Use widget.onPageChange
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
           /* const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  // ... CustomCard row remains the same ...
                   children: [
                    CustomCard(
                      title: 'Market Price',
                      description:
                          'Get the latest market prices for your crops.',
                      onPressed: () {}, width: 300, // Empty onPressed for now
                    ),
                    const SizedBox(width: 8),
                    CustomCard(
                      title: 'Analytics',
                      description: 'View detailed analytics of your farm.',
                      onPressed: () {}, width: 300, // Empty onPressed for now
                    ),
                    const SizedBox(width: 8),
                    CustomCard(
                      title: 'Recommendations',
                      description:
                          'Get personalized recommendations for your farm.',
                      onPressed: () {}, width: 300, // Empty onPressed for now
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),*/
          ],
        ),
      ),
    );
  }

  // --- Helper Widget for Weather Section ---
  Widget _buildWeatherSection() {
    if (_isLoadingWeather) {
      // Show a placeholder card while loading
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Card(
          color: AppColors.primary,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_weatherErrorMessage != null) {
      // Show an error state card
       return AspectRatio(
         aspectRatio: 16 / 9,
         child: Card(
           color: AppColors.primary.withOpacity(0.8),
           child: Center(
             child: Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text(
                  _weatherErrorMessage!,
                  style: const TextStyle(color: Colors.orangeAccent),
                  textAlign: TextAlign.center,
                 ),
             ),
           ),
         ),
       );
    }

    if (_currentWeatherConditions == null) {
       // Show generic unavailable card if data is somehow null after loading
       return const AspectRatio(
        aspectRatio: 16 / 9,
        child: Card(
          color: AppColors.primary,
          child: Center(child: Text("Weather data unavailable", style: TextStyle(color: AppColors.grey))),
        ),
      );
    }

    // --- Data is available, build the actual WeatherCard ---
    String temp = _currentWeatherConditions!['temp']?.toStringAsFixed(0) ?? '--';
    String condition = _currentWeatherConditions!['conditions'] ?? 'N/A';
    // Simplistic prediction for home screen
    String prediction = 'Current: $condition';
    // *** Use the location name fetched via geocoding ***
    String location = _weatherDisplayLocation ?? 'Loading Location...';


    return WeatherCard(
      temperature: temp,
      weatherCondition: condition,
      weatherPridiction: prediction, // Keep it simple for home screen
      description: location, // Display fetched location
      buttonText: 'View More', // Keep this text
      onButtonPressed: () {
        Navigator.pushNamed(context, '/weather'); // Navigate to full weather screen
      },
    );
  }
  // --- End Helper Widget ---
}