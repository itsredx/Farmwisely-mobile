import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ColumnBarChart extends StatelessWidget {
  const ColumnBarChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SfCartesianChart(
              plotAreaBackgroundColor: Colors.transparent,
              margin: EdgeInsets.symmetric(vertical: 32),
              borderColor: Colors.transparent,
              borderWidth: 0,
              plotAreaBorderWidth: 0,
              enableSideBySideSeriesPlacement: false,
              primaryXAxis: CategoryAxis(
                isVisible: false
              ),
              primaryYAxis: NumericAxis(
                isVisible: false,
                minimum: 0,
                maximum: 2,
                interval: 0.5,
              )
            ),
          ],
        ),),
    );
  }
}