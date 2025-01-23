import 'package:farmwisely/widgets/daily_weather_detail.dart';
import 'package:farmwisely/widgets/weather_card.dart';
import 'package:flutter/material.dart';
import 'package:farmwisely/utils/colors.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

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
            onPressed: () {},
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeatherCard(
                  temperature: '33',
                  weatherPridiction: 'Rain fall expected in 2 hours',
                  weatherCondition: 'Humid',
                  description: 'New York',
                  buttonText: 'View More',
                  onButtonPressed: () {},
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Weekly Forecast',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                    day: 'Mon',
                    temperature: '33 c - 34 c',
                    prediction: '20% chance of rain',
                    weatherCondition: 'Sunny',
                    onPressed: () {}),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                    day: 'Tue',
                    temperature: '33 c - 34 c',
                    prediction: '20% chance of rain',
                    weatherCondition: 'Sunny',
                    onPressed: () {}),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                    day: 'Wed',
                    temperature: '33 c - 34 c',
                    prediction: '20% chance of rain',
                    weatherCondition: 'Sunny',
                    onPressed: () {}),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                    day: 'Thu',
                    temperature: '33 c - 34 c',
                    prediction: '20% chance of rain',
                    weatherCondition: 'Sunny',
                    onPressed: () {}),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                    day: 'Fri',
                    temperature: '33 c - 34 c',
                    prediction: '20% chance of rain',
                    weatherCondition: 'Cloudy',
                    onPressed: () {}),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                    day: 'Sat',
                    temperature: '33 c - 34 c',
                    prediction: '20% chance of rain',
                    weatherCondition: 'Sunny',
                    onPressed: () {}),
                const SizedBox(
                  height: 6,
                ),
                DailyWeatherDetail(
                  day: 'Sun',
                  temperature: '33 c - 34 c',
                  prediction: '20% chance of rain',
                  weatherCondition: 'Rainny',
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 16,
                ),
                const Text(
                  'Key Insights',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6,
                ),
                KeyInsightsCard(
                  title: 'Warning',
                  description: 'Heavy rain fall expected on Wed',
                  leadingIcon: Icons.warning_amber_rounded,
                  leadingIconColor: Colors.redAccent,
                ),
                const SizedBox(
                  height: 6,
                ),
                KeyInsightsCard(
                  title: 'Crop-Specific Advice',
                  description:
                      'Irrigation is reccomended tomorrow due to expected high temperature',
                  leadingIcon: Icons.tips_and_updates_rounded,
                  leadingIconColor: AppColors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class KeyInsightsCard extends StatelessWidget {
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
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                leadingIcon,
                color: leadingIconColor,
                size: 40.0,
              ),
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: SizedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
