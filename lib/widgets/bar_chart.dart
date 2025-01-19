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
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  minimum: 0,
                  maximum: 2,
                  interval: 0.5,
                ),
                series: <CartesianSeries>[
                  CandleSeries<ChartColumnData, String>(
                    borderRadius: BorderRadius.circular(20),
                    dataSource: ChartData, 
                    width: 0.5,
                    color: Colors.blueAccent,
                    xValueMapper: (ChartColumnData data, _)=> data.x, 
                    lowValueMapper: (ChartColumnData data, _)=> data.y, 
                    highValueMapper: highValueMapper, 
                    openValueMapper: openValueMapper, 
                    closeValueMapper: closeValueMapper)
                ],
                ),
          ],
        ),
      ),
    );
  }
}

class ChartColumnData {
  ChartColumnData(this.x, this.y, this.y1);
  final String x;
  final double y;
  final double y1;
}

final List<ChartColumnData> ChartData = <ChartColumnData>[
  ChartColumnData('Mo', 2, 1),
  ChartColumnData('Tu', 2, 0.5),
  ChartColumnData('We', 2, 1.5),
  ChartColumnData('Th', 2, 0.8),
  ChartColumnData('Fr', 2, 0.3),
  ChartColumnData('Sa', 2, 1.8),
  ChartColumnData('Su', 2, 0.9),
];