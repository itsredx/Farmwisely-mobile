// widgets/crop_card.dart
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class CropCard extends StatelessWidget {
  final String cropName;
  final String sustainabilityRating; // Changed from 'Raiting'
  final String benefits;
  final String tips;
  final String description; // Added description

  const CropCard({
    super.key,
    required this.cropName,
    required this.sustainabilityRating,
    required this.benefits,
    required this.tips,
    required this.description, // Added required description
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cropName,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Sustainability:', sustainabilityRating),
            _buildInfoRow('Benefits:', benefits),
            _buildInfoRow('Tips:', tips),
             _buildInfoRow('Description:', description), // Display description
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: AppColors.grey),
          children: [
            TextSpan(
                text: '$label ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}