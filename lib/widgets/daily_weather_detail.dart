import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class DailyWeatherDetail extends StatelessWidget {
  final String day;
  final String temperature;
  final String prediction;
  final VoidCallback onPressed;
  const DailyWeatherDetail({
    super.key,
    required this.day,
    required this.temperature,
    required this.prediction,
    required this.onPressed,
  });

  get weatherCondition => null;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Image.asset(
                weatherIcon,
                height: 50,
                width: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Text(
            temperature,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            prediction,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherInsightCard extends StatelessWidget {
  final IconData? leadingIcon;
  final String title;
  final String description;

  const WeatherInsightCard({
    super.key,
    required this.title,
    required this.description, this.leadingIcon,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              leadingIcon,
              color: AppColors.grey,
              size: 40.0,
            ),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
