import 'package:d_chart/d_chart.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


List<OrdinalData> series = [
  OrdinalData(domain: 'Jul', measure: 120),
  OrdinalData(domain: 'Aug', measure: 180),
  OrdinalData(domain: 'Sep', measure: 240),
  OrdinalData(domain: 'Oct', measure: 170),
];

class BarGraph extends StatelessWidget {
  const BarGraph({super.key});

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
              child: DChartBarO(
                vertical: false,
                layoutMargin: LayoutMargin(50, 20, 30, 20),
                configRenderBar: ConfigRenderBar(
                  barGroupInnerPaddingPx: 0,
                  radius: 30,
                ),
                domainAxis: const DomainAxis(
                  showLine: false,
                  tickLength: 0,
                  gapAxisToLabel: 12,
                ),
                measureAxis: MeasureAxis(
                  tickLength: 0,
                  tickLabelFormatter: (measure) {
                    return NumberFormat.compactCurrency(
                      symbol: '\$',
                      decimalDigits: 0,
                    ).format(measure);
                  },
                ),
                groupList: [
                  OrdinalGroup(
                    id: '1',
                    data: series,
                    color: Colors.deepPurple,
                  ),
                ],
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
