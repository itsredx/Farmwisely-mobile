import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class CropCard extends StatelessWidget {
  final String cropName;
  final String sustainabilityRaiting;
  final String benefits;
  final String tips;
  final void Function()? onPressed;

  const CropCard({
    super.key,
    required this.cropName,
    required this.sustainabilityRaiting,
    this.onPressed,
    required this.benefits,
    required this.tips,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          height: 230,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Crop Name',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    cropName,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sustainability Raiting',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    sustainabilityRaiting,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Benefits',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Text(
                        benefits,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tips',
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 90,
                  ),
                  Expanded(
                    child: SizedBox(
                      child: Text(
                        tips,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            color: AppColors.grey,
                            fontSize: 14,
                            fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
              ),
              const Expanded(child: SizedBox(height: 16.0)),
              Align(
                alignment: Alignment.bottomRight,
                child: OutlinedButton(
                  onPressed: () {
                    if (onPressed != null) onPressed!();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.secondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                  ),
                  child: const Text(
                    'Learn More',
                    style: TextStyle(
                      color: AppColors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
