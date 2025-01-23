import 'package:farmwisely/utils/colors.dart';
import 'package:farmwisely/widgets/help_card.dart';
import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

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
        title: Text(
          'Help & About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'App Information',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'App Name',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Farmwisely',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current Version',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '0.0.1',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(
                height: 4,
              ),
              Text(
                'Farmwisely empowers farmers with data driven insights and AI-Based recomendations for improved productivity and sustainability.',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                children: [
                  HelpCard(
                    action: Icons.arrow_drop_down_rounded,
                    text: 'How do i update my farm profile?',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HelpCard(
                    action: Icons.arrow_drop_down_rounded,
                    text: 'what do i do if i encounter incorrect weather data?',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HelpCard(
                    action: Icons.arrow_drop_down_rounded,
                    text: 'How do i contact support?',
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'How-To Guides & Tutorials',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Column(
                children: [
                  HelpCard(
                      action: Icons.play_arrow_rounded,
                      text: 'Setting up your farm profile',),
                  const SizedBox(
                    height: 10,
                  ),
                  HelpCard(
                      action: Icons.play_arrow_rounded,
                      text: 'Undestanding crop recommendation?',),
                  const SizedBox(
                    height: 10,
                  ),
                  HelpCard(
                      action: Icons.play_arrow_rounded,
                      text: 'Navigating analytics report',),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Contact Us',
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
                  HelpCard(
                    action: Icons.call,
                    text: '+2341234567890',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  HelpCard(
                    action: Icons.email,
                    text: 'ambashir02@gmail.com',
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Support available Monday - Friday, 9AM-5AM',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Privacy Policy',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 19, 74, 119),
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                  Text(
                    '|',
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                  Text(
                    'Terms',
                    style: TextStyle(
                        color: const Color.fromARGB(255, 19, 74, 119),
                        fontSize: 12,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
