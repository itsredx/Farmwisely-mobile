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
     String lowerCaseCondition = weatherCondition.toLowerCase();

    String weatherIcon;
    if (lowerCaseCondition.contains('sunny') || lowerCaseCondition.contains('clear')) {
      weatherIcon = 'assets/images/sunny.png';
    } else if (lowerCaseCondition.contains('rain')) {
      weatherIcon = 'assets/images/rainy.png';
    } else if (lowerCaseCondition.contains('cloudy')) {
      weatherIcon = 'assets/images/cloudy.png';
    } else if (lowerCaseCondition.contains('humid')) {
      weatherIcon = 'assets/images/humid_weather_card.png';
    } else if (lowerCaseCondition.contains('drizzle')) {
      weatherIcon = 'assets/images/drizzle_weather_card.png';
    } else if (lowerCaseCondition.contains('foggy')) {
      weatherIcon = 'assets/images/foggy_weather_card.png';
    } else if (lowerCaseCondition.contains('overcast')) {
      weatherIcon = 'assets/images/overcast_weather_card.png';
    } else if (lowerCaseCondition.contains('rainy & snowy')) {
      weatherIcon = 'assets/images/rainy_snowy_weather_card.png';
    } else if (lowerCaseCondition.contains('snowy')) {
      weatherIcon = 'assets/images/snowy_weather_card.png';
    } else if (lowerCaseCondition.contains('windy')) {
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
