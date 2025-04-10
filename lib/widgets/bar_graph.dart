import 'package:d_chart/d_chart.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
//import 'package:intl/intl.dart'; // Keep for NumberFormat if used elsewhere, though not needed for month shortening

class YieldData {
  final String month;
  final num increase;

  YieldData({required this.month, required this.increase});

  factory YieldData.fromJson(Map<String, dynamic> json) {
    return YieldData(
      month: json['month'] ?? 'N/A',
      increase: (json['increase'] is String)
          ? (num.tryParse(json['increase']) ?? 0)
          : (json['increase'] ?? 0),
    );
  }
}


class BarGraph extends StatelessWidget {
  final List<YieldData> yieldDataList;

  const BarGraph({super.key, required this.yieldDataList});

  @override
  Widget build(BuildContext context) {
    // Convert the incoming data to the format DChart expects
    final List<OrdinalData> series = yieldDataList.map((data) {
      // **** ADDED LOGIC TO SHORTEN MONTH NAME ****
      String shortMonth = data.month; // Default to full name
      if (data.month.length >= 3) {
        shortMonth = data.month.substring(0, 3); // Take first 3 characters
      }
      // **** END ADDED LOGIC ****

      return OrdinalData(
        domain: shortMonth, // Use the shortened month name
        measure: data.increase
      );
    }).toList();

    // Handle empty data case for the chart
    if (series.isEmpty) {
      return const Center(child: Text("No yield data available", style: TextStyle(color: AppColors.grey)));
    }

    return Card(
      color: AppColors.primary,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             const Text(
                "Monthly Yield Increase Prediction (%)",
                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
              ),
             const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartBarO(
                vertical: false,
                configRenderBar: ConfigRenderBar(
                   radius: 8,
                   maxBarWidthPx: 25,
                ),
                domainAxis: const DomainAxis(
                  showLine: false,
                  tickLength: 0,
                  gapAxisToLabel: 8,
                  // Adjust font size if needed for shorter labels
                  labelStyle: LabelStyle(color: AppColors.grey, fontSize: 10),
                ),
                measureAxis: MeasureAxis(
                  tickLength: 0,
                  showLine: false,
                  tickLabelFormatter: (measure) {
                    return "${measure?.toStringAsFixed(0) ?? '0'}%";
                  },
                   labelStyle: const LabelStyle(color: AppColors.grey, fontSize: 10),
                ),
                groupList: [
                  OrdinalGroup(
                    id: '1',
                    data: series, // Use dynamic data with shortened domain
                    color: AppColors.secondary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Removed button
          ],
        ),
      ),
    );
  }
}