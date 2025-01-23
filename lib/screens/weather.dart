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
          padding: const EdgeInsets.all(8.0),
          child: Column(
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
                height: 10,
              ),
              const Text(
                'Weekly Forecast',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  DailyWeatherDetail(
                      day: 'Mon',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DailyWeatherDetail(
                      day: 'Tue',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DailyWeatherDetail(
                      day: 'Wed',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DailyWeatherDetail(
                      day: 'Thu',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DailyWeatherDetail(
                      day: 'Fri',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DailyWeatherDetail(
                      day: 'Sat',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                  const SizedBox(
                    height: 10,
                  ),
                  DailyWeatherDetail(
                      day: 'Sun',
                      temperature: '33',
                      prediction: '20% chance of rain',
                      onPressed: () {}),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Key Insights',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  WeatherInsightCard(
                    title: 'Warning',
                    description: 'Heavy rain fall expected on Wed',
                  ),
                  WeatherInsightCard(
                    title: 'Crop-Specific Advice',
                    description: 'Irrigation is reccomended tomorrow due to expected high temperature',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
