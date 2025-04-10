// widgets/alternative_crop_card.dart
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class AlternativeCropCard extends StatelessWidget {
  final String cropName;
  final String sustainabilityRating;
  final String reason;

  const AlternativeCropCard({
    super.key,
    required this.cropName,
    required this.sustainabilityRating,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withOpacity(0.8), // Slightly different color
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0), // Smaller padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cropName,
              style: const TextStyle(
                  fontSize: 16, // Slightly smaller font
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary),
            ),
            const SizedBox(height: 6),
            _buildInfoRow('Sustainability:', sustainabilityRating),
            _buildInfoRow('Reason:', reason),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: AppColors.grey), // Smaller font
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