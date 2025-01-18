import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class RadialBarChart extends StatelessWidget {
  const RadialBarChart({super.key});

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
            const Row(
              children: [
                SizedBox(),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    radiusFactor: 0.5,
                    pointers: const <GaugePointer>[
                      RangePointer(
                        value: 78,
                        cornerStyle: CornerStyle.bothCurve,
                        color: Colors.blueAccent,
                      ),
                    ],
                    interval: 5,
                    startAngle: 5,
                    endAngle: 5,
                    showTicks: false,
                    showLabels: false,
                    annotations: const <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Center(
                          child: SizedBox(
                            width: 100,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '78%',
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Water Use',
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                                Text(
                                  '60%',
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Carbon Footprint',
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: AppColors.grey,
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        angle: 270,
                        positionFactor: 0.1,
                      ),
                    ],
                  ),
                  RadialAxis(
                    radiusFactor: 0.6,
                    pointers: const <GaugePointer>[
                      RangePointer(
                        value: 60,
                        cornerStyle: CornerStyle.bothCurve,
                        color: Colors.pink,
                      ),
                    ],
                    interval: 5,
                    startAngle: 5,
                    endAngle: 5,
                    showTicks: false,
                    showLabels: false,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child:ElevatedButton(
                onPressed: (){},
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 10), backgroundColor: AppColors.secondary,
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
                    fontWeight: FontWeight.bold
                  ),
                  )
            ))
          ],
        ),
      ),
    );
  }
}
