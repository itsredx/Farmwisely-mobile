import 'package:d_chart/d_chart.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

List<OrdinalData> ordinalDataList = [
  OrdinalData(
    domain: 'ROI',
    measure: 60,
    color: Colors.blue,
  ),
  OrdinalData(
    domain: 'Profit',
    measure: 25,
    color: Colors.cyan,
  ),
  OrdinalData(
    domain: 'Operational Expenses',
    measure: 15,
    color: Colors.deepPurple,
  ),
  OrdinalData(
    domain: 'Capital',
    measure: 40,
    color: Colors.amber,
  ),
];

class PieChart extends StatelessWidget {
  const PieChart({super.key});

  @override
  Widget build(BuildContext context) {
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DChartPieO(
                data: ordinalDataList,
                customLabel: (ordinalData, index) {
                  return '${ordinalData.measure}%';
                },
                configRenderPie: ConfigRenderPie(
                  strokeWidthPx: 0,
                  arcWidth: 36,
                  arcLabelDecorator: ArcLabelDecorator(
                    labelPosition: ArcLabelPosition.outside,
                    leaderLineStyle: const ArcLabelLeaderLineStyle(
                      color: Colors.black87,
                      length: 16,
                      thickness: 1,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 16.0,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: AppColors.secondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'View Details',
                  style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
