import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String temperature;
  final String weatherCondition;
  final String weatherPridiction;
  final String description;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const WeatherCard({
    super.key,
    required this.temperature,
    required this.weatherCondition,
    required this.weatherPridiction,
    required this.description,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Determine background image based on subtitle
    String lowerCaseCondition = weatherCondition.toLowerCase();
String backgroundImage;
    if (lowerCaseCondition.contains('sunny') || lowerCaseCondition.contains('clear')) {
      backgroundImage = 'assets/images/sunny_weather_card.png';
    } else if (lowerCaseCondition.contains('rain')) {
      backgroundImage = 'assets/images/rainy_weather_card.png';
    } else if (lowerCaseCondition.contains('cloudy')) {
      backgroundImage = 'assets/images/cloudy_weather_card.png';
    } else if (lowerCaseCondition.contains('humid')) {
      backgroundImage = 'assets/images/humid_weather_card.png';
    }  else if (lowerCaseCondition.contains('drizzle')) {
      backgroundImage = 'assets/images/drizzle_weather_card.png';
    } else if (lowerCaseCondition.contains('foggy')) {
      backgroundImage = 'assets/images/foggy_weather_card.png';
    } else if (lowerCaseCondition.contains('overcast')) {
      backgroundImage = 'assets/images/overcast_weather_card.png';
    } else if (lowerCaseCondition.contains('rainy & snowy')) {
      backgroundImage = 'assets/images/rainy_snowy_weather_card.png';
    } else if (lowerCaseCondition.contains('snowy')) {
      backgroundImage = 'assets/images/snowy_weather_card.png';
    } else if (lowerCaseCondition.contains('windy')) {
      backgroundImage = 'assets/images/windy_weather_card.png';
    } else {
      backgroundImage = 'assets/images/default_weather_card.png.jpg';
    }

    return AspectRatio(
      aspectRatio: 16 / 9, // Maintains 16:9 aspect ratio
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(backgroundImage), fit: BoxFit.cover),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.black
                .withOpacity(0.0), // Adds a semi-transparent overlay
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$temperature°c',
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                weatherCondition,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 3),
              if (weatherPridiction.isNotEmpty)
                Text(
                  '',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                  ),
                ),
              const Expanded(child: SizedBox()),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: onButtonPressed,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View More',
                      style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                    ),
                    Icon(
                      Icons.arrow_right,
                      color: AppColors.grey,
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      );
    
  }
}
