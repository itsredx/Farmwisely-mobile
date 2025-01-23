import 'package:flutter/material.dart';
import '../widgets/weather_card.dart';
import '../widgets/custom_card.dart';
import '../widgets/info_card.dart'; // Import the WeatherCard widget

class Home extends StatelessWidget {
  const Home({super.key, required this.onPageChange});
  final Function(int) onPageChange;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            WeatherCard(
              temperature: '33',
              weatherPridiction: 'Rain fall expected in 2 hours',
              weatherCondition: 'Humid',
              description: 'New York',
              buttonText: 'View More',
              onButtonPressed: () {
                Navigator.pushNamed(context, '/weather');
              },
            ),
            const SizedBox(
              height: 16,
            ),
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
                          onPageChange(1);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
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
                const SizedBox(
                  height: 16,
                ),
                Row(
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
                        title: 'Waather Forecast',
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
                          onPageChange(2);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
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
            ), // Display the WeatherCard
            const SizedBox(
              height: 16,
            ),
            // Other home screen content can be added here
          ],
        ),
      ),
    );
  }
}
