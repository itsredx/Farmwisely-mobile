import 'dart:convert';
import 'package:farmwisely/widgets/daily_weather_detail.dart';
import 'package:farmwisely/widgets/weather_card.dart';
import 'package:flutter/material.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package

// Convert to StatefulWidget
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData;
  String? _token;
  String? _latitude;
  String? _longitude;

  @override
  void initState() {
    super.initState();
    _loadPrerequisitesAndFetchWeather();
  }

  Future<void> _loadPrerequisitesAndFetchWeather() async {
     if (!mounted) return;
    setState(() => _isLoading = true); // Start loading

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? farmDataString = prefs.getString('farmData');
    String? lat;
    String? lon;

    if (farmDataString != null) {
      try {
        final Map<String, dynamic> farmData = json.decode(farmDataString);
        // Assuming keys are 'latitude' and 'longitude', convert to string
        lat = farmData['latitude']?.toString();
        lon = farmData['longitude']?.toString();
      } catch (e) {
        print("Error decoding farm data: $e");
         if (!mounted) return;
        setState(() {
          _errorMessage = "Error reading farm location data.";
          _isLoading = false;
        });
        return;
      }
    }

    if (token != null && lat != null && lon != null) {
       if (!mounted) return;
      setState(() {
        _token = token;
        _latitude = lat;
        _longitude = lon;
      });
      await _fetchWeatherData(); // Fetch weather data
    } else {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Farm location or authentication token not found.";
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_token == null || _latitude == null || _longitude == null) {
      setState(() {
        _errorMessage = "Missing required data (token/location) to fetch weather.";
        _isLoading = false;
      });
      return;
    }

     if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous error
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
          _weatherData = decodedData;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load weather data (Status: ${response.statusCode}): ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred fetching weather: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // Helper to get day name from epoch seconds
  String _getDayFromEpoch(int epochSeconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    return DateFormat('E').format(dateTime); // 'E' gives short day name (e.g., Mon)
  }

  // Helper to format temperature range
  String _formatTempRange(dynamic tempMax, dynamic tempMin) {
    final max = tempMax?.toStringAsFixed(0) ?? '--';
    final min = tempMin?.toStringAsFixed(0) ?? '--';
    return "$min°C - $max°C";
  }

  // Helper to format rain probability
  String _formatPrecipProb(dynamic prob) {
     if (prob == null) return '--% chance';
     // API might return 0-100 or 0.0-1.0, adjust if needed
     final probPercent = (prob is double && prob <= 1.0) ? (prob * 100) : prob;
     return "${probPercent?.toStringAsFixed(0) ?? '--'}% chance";
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // ... (AppBar leading and title remain the same) ...
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
              'Weather Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Stay up to date with weather forecast tailored to your farm',
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Refresh Weather",
            onPressed: _isLoading ? null : _fetchWeatherData, // Call fetch method
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      // Use a builder for the body content based on state
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: $_errorMessage',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center)));
    }

    if (_weatherData == null) {
      return const Center(child: Text('No weather data available.'));
    }

    // --- Data Loaded - Extract and Display ---
    final currentConditions = _weatherData!['currentConditions'];
    final days = _weatherData!['days'] as List<dynamic>? ?? []; // Forecast days
    final alerts = _weatherData!['alerts'] as List<dynamic>? ?? []; // Weather alerts

    String currentTemp = currentConditions?['temp']?.toStringAsFixed(0) ?? '--';
    String currentCondition = currentConditions?['conditions'] ?? 'N/A';
    // Simple 'prediction' - maybe mention if rain is coming soon from hourly? (More complex)
    // Or just use current condition again, or an alert summary.
    String simplePrediction = alerts.isNotEmpty
        ? alerts[0]['event'] ?? 'Weather Alert Active'
        : 'Conditions: $currentCondition';
    String location = _weatherData!['resolvedAddress'] ?? 'Your Farm Location';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        // Removed the extra Expanded widget here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeatherCard(
              temperature: currentTemp,
              weatherPridiction: simplePrediction, // Use a generated prediction/alert
              weatherCondition: currentCondition,
              description: location, // Use resolved address
              buttonText: 'View Details', // Example
              onButtonPressed: () {
                // TODO: Implement navigation to a more detailed view if needed
              },
            ),
            const SizedBox(height: 16),

            const Text(
              'Weekly Forecast',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

            // --- Daily Forecast List ---
             if (days.isEmpty)
               const Text('Weekly forecast data not available.', style: TextStyle(color: AppColors.grey))
             else
               ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: days.length > 7 ? 7 : days.length, // Show max 7 days
                  itemBuilder: (context, index) {
                    final dayData = days[index];
                    return DailyWeatherDetail(
                      day: _getDayFromEpoch(dayData['datetimeEpoch']),
                      temperature: _formatTempRange(dayData['tempmax'], dayData['tempmin']),
                      prediction: _formatPrecipProb(dayData['precipprob']),
                      weatherCondition: dayData['conditions'] ?? 'N/A',
                      onPressed: () {
                        // TODO: Show hourly details for this day?
                      });
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
               ),

            const SizedBox(height: 16),

            // --- Key Insights / Alerts ---
            const Text(
              'Key Insights & Alerts',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),

             if (alerts.isEmpty)
               const Padding(
                 padding: EdgeInsets.symmetric(vertical: 8.0),
                 child: Text('No active weather alerts.', style: TextStyle(color: AppColors.grey)),
               )
             else
               ListView.builder(
                 physics: const NeverScrollableScrollPhysics(),
                 shrinkWrap: true,
                 itemCount: alerts.length,
                 itemBuilder: (context, index) {
                    final alert = alerts[index];
                    // Determine icon/color based on severity or event type (needs customization)
                    IconData alertIcon = Icons.warning_amber_rounded;
                    Color alertColor = Colors.orangeAccent;
                    if (alert['event']?.toLowerCase().contains('warning')) {
                       alertColor = Colors.redAccent;
                    } else if (alert['event']?.toLowerCase().contains('watch')) {
                       alertColor = Colors.yellow.shade700;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: KeyInsightsCard(
                        title: alert['event'] ?? 'Alert',
                        description: alert['headline'] ?? 'Details unavailable.',
                        leadingIcon: alertIcon,
                        leadingIconColor: alertColor,
                      ),
                    );
                 },
               ),

            // You can add custom insights based on weather data here if needed
            // e.g., High temperature warning, planting conditions advice, etc.
             _buildCustomInsightCardIfNeeded(currentConditions, days), // Example

             const SizedBox(height: 16), // Bottom padding
          ],
        ),
      ),
    );
  }

   // Example of generating a custom insight card
   Widget _buildCustomInsightCardIfNeeded(Map<String, dynamic>? current, List<dynamic> forecastDays) {
     // Example: Check if temperature is very high today or tomorrow
     double? todayMaxTemp = forecastDays.isNotEmpty ? forecastDays[0]['tempmax'] : null;
     double? currentTemp = current?['temp'];
     bool isHot = (currentTemp != null && currentTemp > 35) || (todayMaxTemp != null && todayMaxTemp > 35);

     if (isHot) {
       return const Padding(
         padding: EdgeInsets.only(top: 6.0),
         child: KeyInsightsCard(
           title: 'High Temperature Advice',
           description: 'Temperatures are high. Ensure adequate irrigation for crops and consider heat stress mitigation.',
           leadingIcon: Icons.thermostat_auto_rounded,
           leadingIconColor: Colors.orangeAccent,
         ),
       );
     }
     return const SizedBox.shrink(); // Return empty if no relevant insight
   }


} // End of _WeatherScreenState

// KeyInsightsCard Definition (assuming it's in the same file or imported)
class KeyInsightsCard extends StatelessWidget {
  // ... (Keep the KeyInsightsCard code as you provided) ...
  final String title;
  final String description;
  final IconData? leadingIcon;
  final Color? leadingIconColor;

  const KeyInsightsCard({
    super.key,
    required this.title,
    required this.description,
    this.leadingIcon, this.leadingIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: AppColors.primary,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Adjusted padding
          child: Row(
            children: [
              if (leadingIcon != null) // Only show icon if provided
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    leadingIcon,
                    color: leadingIconColor ?? AppColors.grey, // Default color
                    size: 36.0, // Adjusted size
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 15, // Adjusted size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4), // Added spacing
                    Text(
                      description,
                      // maxLines: 4, // Allow wrapping
                      // overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14.0, // Adjusted size
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Make sure DailyWeatherDetail and WeatherCard are imported or defined
// Example modification needed for DailyWeatherDetail (if not already done):
/*
class DailyWeatherDetail extends StatelessWidget {
  final String day;
  final String temperature; // Now expects range like "25°C - 35°C"
  final String prediction; // Now expects rain chance like "20% chance"
  final String weatherCondition;
  final VoidCallback onPressed;

  const DailyWeatherDetail({
    Key? key,
    required this.day,
    required this.temperature,
    required this.prediction,
    required this.weatherCondition,
    required this.onPressed,
  }) : super(key: key);

 // ... rest of DailyWeatherDetail implementation using these props ...
}
*/

// Example modification needed for WeatherCard (if not already done):
/*
class WeatherCard extends StatelessWidget {
  final String temperature; // Expects string like "33"
  final String weatherPrediction; // Expects string like "Conditions: Humid" or an alert
  final String weatherCondition;
  final String description; // Expects location string
  final String buttonText;
  final VoidCallback onButtonPressed;

  const WeatherCard({
     Key? key,
     required this.temperature,
     required this.weatherPrediction,
     required this.weatherCondition,
     required this.description,
     required this.buttonText,
     required this.onButtonPressed,
   }) : super(key: key);

 // ... rest of WeatherCard implementation using these props ...
 // Remember to format temperature with °C inside the build method
}
*/