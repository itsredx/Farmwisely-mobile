import 'dart:convert';
import 'package:farmwisely/widgets/daily_weather_detail.dart';
import 'package:farmwisely/widgets/weather_card.dart';
import 'package:farmwisely/widgets/weather_detail_popup.dart';
import 'package:flutter/material.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // Import intl package
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _weatherData; // Holds the full weather API response
  String? _displayLocationName; // Holds the name from geocoding
  String? _token;
  double? _latitude; // Changed to double
  double? _longitude; // Changed to double

  @override
  void initState() {
    super.initState();
    _loadPrerequisitesAndFetchData(); // Combined loading function
  }

  Future<void> _loadPrerequisitesAndFetchData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? farmDataString = prefs.getString('farmData');
    double? lat;
    double? lon;

    if (farmDataString != null) {
      try {
        final Map<String, dynamic> farmData = json.decode(farmDataString);
        // Parse lat/lon as double
        lat = (farmData['latitude'] is num) ? (farmData['latitude'] as num).toDouble() : double.tryParse(farmData['latitude']?.toString() ?? '');
        lon = (farmData['longitude'] is num) ? (farmData['longitude'] as num).toDouble() : double.tryParse(farmData['longitude']?.toString() ?? '');
      } catch (e) {
        print("WeatherScreen - Error decoding farm data: $e");
      }
    }

    if (token != null && lat != null && lon != null) {
      if (!mounted) return;
      setState(() {
        _token = token;
        _latitude = lat;
        _longitude = lon;
      });
      // Fetch weather and location name concurrently
      await Future.wait([
        _fetchWeatherData(),
        _fetchLocationName(),
      ]);
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Farm location or authentication token not found.";
      });
    }
     // Ensure loading stops even if prerequisites fail before fetch calls
     if (mounted && _isLoading) {
       setState(() => _isLoading = false);
     }
  }

  Future<void> _fetchWeatherData() async {
     if (_token == null || _latitude == null || _longitude == null) return;

    // Loading state managed by the combined function

    try {
      final String apiUrl = 'https://devred.pythonanywhere.com/api/weather/${_latitude!.toString()}/${_longitude!.toString()}/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Token $_token'},
      );

       if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          _weatherData = decodedData;
          // Don't set error message if successful
        });
      } else {
        setState(() {
          // Only set error if no other error exists (e.g., from geocoding)
           _errorMessage ??= "Failed to load weather data (Status: ${response.statusCode}): ${response.body}";
        });
      }
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _errorMessage ??= "An error occurred fetching weather: ${e.toString()}";
      });
    }
  }

   // --- Function for Reverse Geocoding ---
  Future<void> _fetchLocationName() async {
     if (_latitude == null || _longitude == null) return;

     try {
       List<Placemark> placemarks = await placemarkFromCoordinates(
         _latitude!,
         _longitude!,
       );

       if (!mounted) return;

       if (placemarks.isNotEmpty) {
         Placemark place = placemarks[0];
         // Construct a display name (e.g., City, State) - Customize as needed
         String displayName = "${place.locality ?? place.subAdministrativeArea ?? ''}${place.locality != null && place.administrativeArea != null ? ', ' : ''}${place.administrativeArea ?? ''}";
          if (displayName.trim().isEmpty) {
           displayName = place.street ?? place.name ?? 'Nearby Location'; // Fallback
         }
         setState(() {
           _displayLocationName = displayName.trim();
         });
       } else {
          setState(() {
           _displayLocationName = "Unknown Location";
         });
       }
     } catch (e) {
       if (!mounted) return;
       print("WeatherScreen - Geocoding error: $e");
        setState(() {
         _displayLocationName = "Location Name N/A";
         // Optionally set the main error message if geocoding fails critically
         // if (_errorMessage == null) {
         //    _errorMessage = "Could not determine location name.";
         // }
       });
     }
  }
  // --- End Geocoding Function ---

  // --- New Method to Show Popup ---
  void _showWeatherDetailPopup() {
    // Ensure we have data before showing the popup
    if (_weatherData == null || _weatherData!['currentConditions'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Weather details not available yet.")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WeatherDetailPopup(
          currentConditions: _weatherData!['currentConditions'],
          locationName: _displayLocationName, // Pass the fetched location name
        );
      },
    );
  }
  // --- End New Method ---


  // --- Formatting Helpers ---
  String _getDayFromEpoch(int epochSeconds) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochSeconds * 1000);
    return DateFormat('E').format(dateTime);
  }

  String _formatTempRange(dynamic tempMax, dynamic tempMin) {
    final max = tempMax?.toStringAsFixed(0) ?? '--';
    final min = tempMin?.toStringAsFixed(0) ?? '--';
    return "$min°C - $max°C";
  }

  String _formatPrecipProb(dynamic prob) {
    if (prob == null) return '--% chance';
    final probPercent = (prob is double && prob <= 1.0) ? (prob * 100) : prob;
    return "${probPercent?.toStringAsFixed(0) ?? '--'}% chance";
  }
  // --- End Formatting Helpers ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
            // Call combined function to refresh everything
            onPressed: _isLoading ? null : _loadPrerequisitesAndFetchData,
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Display error first if it exists
    if (_errorMessage != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: $_errorMessage',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center)));
    }

    // Check if weather data is still null after loading and no error
    if (_weatherData == null) {
      return const Center(child: Text('Weather data could not be loaded.'));
    }

    // --- Data Loaded - Extract and Display ---
    final currentConditions = _weatherData!['currentConditions'];
    final days = _weatherData!['days'] as List<dynamic>? ?? [];
    final alerts = _weatherData!['alerts'] as List<dynamic>? ?? [];

    String currentTemp = currentConditions?['temp']?.toStringAsFixed(0) ?? '--';
    String currentCondition = currentConditions?['conditions'] ?? 'N/A';
    String simplePrediction = alerts.isNotEmpty
        ? alerts[0]['event'] ?? 'Weather Alert Active'
        : 'Conditions: $currentCondition';

    // *** Use the geocoded location name ***
    String location = _displayLocationName ?? 'Loading Location...';

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WeatherCard(
              temperature: currentTemp,
              weatherPridiction: simplePrediction,
              weatherCondition: currentCondition,
              description: location, // Pass geocoded location
              buttonText: 'View Details',
              onButtonPressed: _showWeatherDetailPopup,
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
                  itemCount: days.length > 7 ? 7 : days.length,
                  itemBuilder: (context, index) {
                    final dayData = days[index];
                    return DailyWeatherDetail(
                      day: _getDayFromEpoch(dayData['datetimeEpoch']),
                      temperature: _formatTempRange(dayData['tempmax'], dayData['tempmin']),
                      prediction: _formatPrecipProb(dayData['precipprob']),
                      weatherCondition: dayData['conditions'] ?? 'N/A',
                      onPressed: () {
                        // TODO: Show hourly details
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
                    IconData alertIcon = Icons.info_outline; // Default icon
                    Color alertColor = Colors.blueAccent;    // Default color

                    String eventLower = alert['event']?.toLowerCase() ?? '';
                    if (eventLower.contains('warning')) {
                      alertIcon = Icons.warning_amber_rounded;
                      alertColor = Colors.redAccent;
                    } else if (eventLower.contains('watch')) {
                      alertIcon = Icons.watch_later_outlined; // Example different icon
                      alertColor = Colors.orangeAccent;
                    } else if (eventLower.contains('advisory')) {
                       alertIcon = Icons.info_outline;
                       alertColor = Colors.lightBlue;
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

             _buildCustomInsightCardIfNeeded(currentConditions, days),

             const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

   Widget _buildCustomInsightCardIfNeeded(Map<String, dynamic>? current, List<dynamic> forecastDays) {
     // ... (implementation remains the same) ...
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
     return const SizedBox.shrink();
   }

} // End of _WeatherScreenState


// KeyInsightsCard Definition (keep as is)
class KeyInsightsCard extends StatelessWidget {
 // ...
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
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              if (leadingIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Icon(
                    leadingIcon,
                    color: leadingIconColor ?? AppColors.grey,
                    size: 36.0,
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
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14.0,
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

// Ensure DailyWeatherDetail and WeatherCard widgets are defined or imported
// and accept the data types being passed (Strings).