// widgets/weather_detail_popup.dart (or place it within weather_screen.dart if preferred)
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:farmwisely/utils/colors.dart'; // Assuming AppColors are here
import 'package:intl/intl.dart';

class WeatherDetailPopup extends StatelessWidget {
  final Map<String, dynamic>? currentConditions;
  final String? locationName;

  const WeatherDetailPopup({
    super.key,
    required this.currentConditions,
    required this.locationName,
  });

  // Helper to safely get and format data
  String _formatData(dynamic value, {String unit = '', int fractionDigits = 0, String fallback = '--'}) {
    if (value == null) return fallback;
    if (value is num) {
      return "${value.toStringAsFixed(fractionDigits)}$unit";
    }
    return value.toString();
  }

   // Helper to format time from epoch
   String _formatTime(dynamic epochSeconds, {String fallback = '--'}) {
     if (epochSeconds == null || epochSeconds is! num) return fallback;
     try {
        final dateTime = DateTime.fromMillisecondsSinceEpoch((epochSeconds).toInt() * 1000);
       return DateFormat.jm().format(dateTime); // Format like "5:08 PM"
     } catch (e) {
       return fallback;
     }
   }

  @override
  Widget build(BuildContext context) {
    if (currentConditions == null) {
      return const Dialog( // Or AlertDialog
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Current weather details are unavailable."),
        ),
      );
    }

    // Extract data safely
    final temp = _formatData(currentConditions!['temp'], unit: '°C', fractionDigits: 0);
    final feelsLike = _formatData(currentConditions!['feelslike'], unit: '°C', fractionDigits: 0);
    final humidity = _formatData(currentConditions!['humidity'], unit: '%', fractionDigits: 0);
    final precip = _formatData(currentConditions!['precip'], unit: ' mm', fractionDigits: 1);
    final windSpeed = _formatData(currentConditions!['windspeed'], unit: ' km/h', fractionDigits: 0);
    final windDir = _formatData(currentConditions!['winddir'], unit: '°');
    final pressure = _formatData(currentConditions!['pressure'], unit: ' hPa', fractionDigits: 0);
    final visibility = _formatData(currentConditions!['visibility'], unit: ' km', fractionDigits: 0);
    final uvIndex = _formatData(currentConditions!['uvindex'], fractionDigits: 0);
    final conditions = currentConditions!['conditions'] ?? 'N/A';
    final sunrise = _formatTime(currentConditions!['sunriseEpoch']);
    final sunset = _formatTime(currentConditions!['sunsetEpoch']);
    final icon = currentConditions!['icon']; // You might map this to local icons later

    return AlertDialog(
      backgroundColor: AppColors.primary, // Use app colors
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      title: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            locationName ?? 'Current Conditions',
            style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
          ),
           IconButton(
             icon: const Icon(Icons.close, color: AppColors.grey),
             onPressed: () => Navigator.of(context).pop(),
             padding: EdgeInsets.zero,
             constraints: const BoxConstraints(),
            )
        ],
      ),
      content: SingleChildScrollView( // Make content scrollable
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum space needed
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Center(
               child: Text(
                 conditions,
                 style: const TextStyle(color: AppColors.grey, fontSize: 18, fontWeight: FontWeight.w500),
                 textAlign: TextAlign.center,
               ),
             ),
             const SizedBox(height: 15),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                  _buildDetailItem(Icons.thermostat, "Feels Like", feelsLike),
                  _buildDetailItem(Icons.water_drop_outlined, "Humidity", humidity),
               ],
             ),
              const SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 _buildDetailItem(Icons.umbrella_outlined, "Precipitation", precip),
                 _buildDetailItem(Icons.air, "Wind Speed", windSpeed),
               ],
             ),
              const SizedBox(height: 10),
              Row(
               mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 _buildDetailItem(Icons.explore_outlined, "Wind Direction", windDir),
                 _buildDetailItem(Icons.speed_outlined, "Pressure", pressure),

               ],
             ),
             const SizedBox(height: 10),
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
               children: [
                 _buildDetailItem(Icons.visibility_outlined, "Visibility", visibility),
                  _buildDetailItem(Icons.wb_sunny_outlined, "UV Index", uvIndex),
               ],
             ),
             const SizedBox(height: 10),
              //Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
               // children: [
                //  _buildDetailItem(Icons.sunrise, "Sunrise", sunrise), // Custom icon maybe
                //  _buildDetailItem(Icons.sunset, "Sunset", sunset), // Custom icon maybe
               // ],
           ///   ),

          ],
        ),
      ),
      // Optional: Add actions if needed, otherwise remove
      // actions: [
      //   TextButton(
      //     child: const Text('Close', style: TextStyle(color: AppColors.secondary)),
      //     onPressed: () {
      //       Navigator.of(context).pop();
      //     },
      //   ),
      // ],
    );
  }

  // Helper widget for individual detail items in the popup
  Widget _buildDetailItem(IconData icon, String label, String value) {
     return Column(
       children: [
         Icon(icon, color: AppColors.secondary, size: 28),
         const SizedBox(height: 4),
         Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
         const SizedBox(height: 2),
         Text(value, style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
       ],
     );
  }
}