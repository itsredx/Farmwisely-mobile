// radial_chart.dart
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart'; // Ensure this is imported

class RadialBarChart extends StatelessWidget {
  final double waterUsageValue; // Expect percentage value (0-100)
  final String waterUsageDescription;
  final String carbonFootprintValue; // Expect string like "120kg CO₂/ha"
  final String carbonFootprintDescription;


  const RadialBarChart({
    super.key,
    required this.waterUsageValue,
    required this.waterUsageDescription,
    required this.carbonFootprintValue,
    required this.carbonFootprintDescription,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure value is within 0-100 range for gauge
     final double clampedWaterUsage = waterUsageValue.clamp(0.0, 100.0);

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
             const Text( // Added Title
                "Environmental Impact",
                style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16), // Add some vertical padding
              child: Center( // Center the gauge
                child: SizedBox(
                   height: 180, // Give the gauge a specific height
                   width: 180, // And width
                  child: SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                         minimum: 0,
                         maximum: 100,
                        pointers: <GaugePointer>[
                          RangePointer(
                            value: clampedWaterUsage,
                            cornerStyle: CornerStyle.bothCurve,
                            color: Colors.blueAccent.shade100,
                             width: 0.15,
                             // *** FIX: Use widthUnit ***
                             sizeUnit: GaugeSizeUnit.factor, // Correct parameter
                          ),
                           MarkerPointer(
                            value: clampedWaterUsage,
                            markerHeight: 10,
                            markerWidth: 10,
                            markerType: MarkerType.circle,
                            color: Colors.blueAccent.shade700,
                          )
                        ],
                        interval: 20,
                        startAngle: 135,
                        endAngle: 45,
                        showTicks: true,
                        showLabels: true,
                         labelOffset: 15,
                         axisLabelStyle: const GaugeTextStyle(fontSize: 10, color: AppColors.grey),
                         majorTickStyle: MajorTickStyle(
                           length: 0.1,
                           // *** FIX: Use lengthUnit ***
                           lengthUnit: GaugeSizeUnit.factor, // Correct parameter
                           thickness: 1.5,
                           color: AppColors.grey
                         ),
                         minorTickStyle: MinorTickStyle(
                           length: 0.05,
                            // *** FIX: Use lengthUnit ***
                           lengthUnit: GaugeSizeUnit.factor, // Correct parameter
                           thickness: 1.0,
                           color: AppColors.grey
                         ),
                         minorTicksPerInterval: 3,
                         axisLineStyle: AxisLineStyle(
                           thickness: 0.15,
                            // *** FIX: Use thicknessUnit ***
                           thicknessUnit: GaugeSizeUnit.factor, // Correct parameter
                           color: AppColors.grey.withOpacity(0.2),
                           cornerStyle: CornerStyle.bothCurve,
                         ),
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(
                            widget: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text(
                                   '${waterUsageValue.toStringAsFixed(0)}%',
                                   style: const TextStyle(
                                     color: Colors.blueAccent,
                                     fontSize: 22,
                                     fontWeight: FontWeight.bold,
                                   ),
                                 ),
                                 const Text(
                                  'Water Use',
                                  style: TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500
                                      ),
                                ),
                              ],
                            ),
                            angle: 90,
                            positionFactor: 0.1,
                          ),
                        ],
                      ),
                       // Removed the second RadialAxis as it wasn't being used dynamically
                    ],
                  ),
                ),
              ),
             ),
             const Divider(color: AppColors.grey, height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     const Text("Water Usage Note:", style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                     Text(waterUsageDescription, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                     const SizedBox(height: 8),
                      Text("Carbon Footprint: $carbonFootprintValue", style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(carbonFootprintDescription, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
             // Removed the generic "View Details" button
          ],
        ),
      ),
    );
  }
}