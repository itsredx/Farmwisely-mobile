import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class DailyWeatherDetail extends StatelessWidget {
  final String day;
  final String temperature;
  final String prediction;
  final String weatherCondition;
  final VoidCallback onPressed;
  const DailyWeatherDetail({
    super.key,
    required this.day,
    required this.temperature,
    required this.prediction,
    required this.onPressed, required this.weatherCondition,
  });


  @override
  Widget build(BuildContext context) {
    String weatherIcon;
    if (weatherCondition.contains('Sunny')) {
      weatherIcon = 'assets/images/sunny.png';
    } else if (weatherCondition.contains('Rain')) {
      weatherIcon = 'assets/images/rainy.png';
    } else if (weatherCondition.contains('Cloudy')) {
      weatherIcon = 'assets/images/cloudy.png';
    } else if (weatherCondition.contains('Humid')) {
      weatherIcon = 'assets/images/humid_weather_card.png';
    } else if (weatherCondition.contains('Cloudy')) {
      weatherIcon = 'assets/images/cloudy_weather_card.png';
    } else if (weatherCondition.contains('Drizzle')) {
      weatherIcon = 'assets/images/drizzle_weather_card.png';
    } else if (weatherCondition.contains('Foggy')) {
      weatherIcon = 'assets/images/foggy_weather_card.png';
    } else if (weatherCondition.contains('Overcast')) {
      weatherIcon = 'assets/images/overcast_weather_card.png';
    } else if (weatherCondition.contains('Rainy & Snowy')) {
      weatherIcon = 'assets/images/rainy_snowy_weather_card.png';
    } else if (weatherCondition.contains('Snowy')) {
      weatherIcon = 'assets/images/snowy_weather_card.png';
    } else if (weatherCondition.contains('Windy')) {
      weatherIcon = 'assets/images/windy_weather_card.png';
    } else {
      weatherIcon = 'assets/images/error.png';
    }
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: AppColors.primary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Image.asset(
                  weatherIcon,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    temperature,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    prediction,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
