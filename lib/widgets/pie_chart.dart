import 'package:d_chart/d_chart.dart';
import 'package:farmwisely/utils/colors.dart';
import 'package:flutter/material.dart';

// Data class for Cost/Profit information
class CostProfitData {
  final String metric;
  final num value; // Using num to accept int or double from JSON
  final String description;
  final Color color; // Color associated with this slice

  CostProfitData({
    required this.metric,
    required this.value,
    required this.description,
    required this.color,
  });

  // Factory constructor to easily create instances from a JSON map
  factory CostProfitData.fromJson(Map<String, dynamic> json, Color defaultColor) {
    return CostProfitData(
      metric: json['metric'] ?? 'N/A', // Provide default if key is missing
      // Safely parse 'value', handling potential String or num types
      value: (json['value'] is String)
          ? (num.tryParse(json['value']) ?? 0) // Try parsing if it's a String
          : (json['value'] ?? 0), // Otherwise, use as num or default to 0
      description: json['description'] ?? '', // Default to empty string
      color: defaultColor, // Use the color passed during creation
    );
  }
}

// The PieChart widget itself
class PieChart extends StatelessWidget {
  // Accepts a list of CostProfitData objects
  final List<CostProfitData> costProfitList;

  const PieChart({super.key, required this.costProfitList});

  // Helper function to determine the color for each pie slice
  // Can be based on the metric name or simply cycle through colors
  Color _getColorForMetric(String metric, int index) {
    // Define a specific color mapping for known metrics
    const colorMap = {
      'ROI': Colors.blueAccent,
      'Profit': Colors.greenAccent,
      'Operational Expenses': Colors.redAccent, // Example: Use red for expenses
      'Capital': Colors.purpleAccent,
    };
    // Provide fallback colors in case the metric name isn't in the map
    final fallbackColors = [Colors.cyan, Colors.amber, Colors.pink, Colors.teal];
    // Return the specific color if found, otherwise use a fallback based on index
    return colorMap[metric] ?? fallbackColors[index % fallbackColors.length];
  }

  @override
  Widget build(BuildContext context) {
    // Convert the input CostProfitData list into the OrdinalData list required by DChart
    // Use asMap().entries to get both index and data for color assignment
    final List<OrdinalData> ordinalDataList = costProfitList.asMap().entries.map((entry) {
      int index = entry.key;      // Index of the data item
      CostProfitData data = entry.value; // The CostProfitData object

      // Create OrdinalData for the chart
      return OrdinalData(
        domain: data.metric, // Use metric name as the domain label
        measure: data.value, // Use the numeric value as the measure
        color: _getColorForMetric(data.metric, index), // Assign color using the helper
      );
    }).toList();

    // Handle the case where there might be no data to display
    if (ordinalDataList.isEmpty) {
      return const Card( // Show within a card for consistency
        color: AppColors.primary,
        child: Center(
            heightFactor: 5, // Give it some height
            child: Text("No cost/profit data available", style: TextStyle(color: AppColors.grey))
        ),
      );
    }

    // Build the Card containing the Pie Chart
    return Card(
      color: AppColors.primary,
      surfaceTintColor: AppColors.primary, // For Material 3 theming consistency
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
          children: [
            // Chart Title
            const Text(
              "Cost-Profit Breakdown (%)",
              style: TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10), // Spacing below title

            // AspectRatio ensures the chart maintains its shape
            AspectRatio(
              aspectRatio: 16 / 10, // Adjusted aspect ratio for potentially more label space
              child: DChartPieO(
                // Provide the data prepared for the chart
                data: ordinalDataList,
                // Define how the label text should be formatted
                customLabel: (ordinalData, index) {
                  // Display metric name on one line, percentage on the next
                   return '${ordinalData.domain}\n${ordinalData.measure}%';
                },
                // Configure the rendering of the pie chart itself
                configRenderPie: ConfigRenderPie(
                  strokeWidthPx: 2, // Optional border width between slices
                  arcWidth: 36, // Uncomment this line to make it a Donut Chart

                  // Configuration for the labels and leader lines (arrows)
                  arcLabelDecorator: ArcLabelDecorator(
                    // Position labels outside the pie slices
                    labelPosition: ArcLabelPosition.outside,
                    // Style for the leader lines connecting slices to labels
                    leaderLineStyle: const ArcLabelLeaderLineStyle(
                      color: AppColors.grey, // Line color
                      length: 20,           // Length of the straight part of the line
                      thickness: 1,
                    ),
                    // Style for the text of the labels themselves
                    outsideLabelStyle: const LabelStyle(
                      color: AppColors.grey,
                      fontSize: 10,       // Font size for labels
                    ),
                    // labelPadding: 5,   // Optional padding between line end and label text
                    // showLeaderLines: true, // Ensure lines are shown (default is true)
                  ),
                ),
              ),
            ),
            // Optional: Add spacing below the chart if needed
            // const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}