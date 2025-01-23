import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

class HelpCard extends StatelessWidget {
  final IconData action;
  final String text;
  const HelpCard({super.key, required this.action, required this.text});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.secondary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text),
              Icon(action),
            ],
          ),
        ),
      ),
    );
  }
}
