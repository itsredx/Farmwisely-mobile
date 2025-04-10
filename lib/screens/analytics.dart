import 'dart:convert';
import 'package:farmwisely/utils/colors.dart';
import 'package:farmwisely/widgets/bar_graph.dart';
import 'package:farmwisely/widgets/custom_card.dart';
import 'package:farmwisely/widgets/pie_chart.dart';
import 'package:farmwisely/widgets/radial_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Import http
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_prefs

class Analytics extends StatefulWidget {
  const Analytics({super.key, required this.onPageChange});
  final Function(int) onPageChange;

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  // State Variables
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _analyticsData;
  String? _token;
  int? _farmId;

  // Default/Empty data for charts to avoid null issues before loading
  List<YieldData> _yieldData = [];
  List<CostProfitData> _costProfitData = [];
  double _waterUsageValue = 0.0;
  String _waterUsageDescription = "Loading...";
  String _carbonFootprintValue = "--";
  String _carbonFootprintDescription = "Loading...";
  List<String> _recommendations = [];


  @override
  void initState() {
    super.initState();
    _loadPrerequisitesAndFetch();
  }

  // --- Data Loading ---
  Future<void> _loadPrerequisitesAndFetch() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final int? farmId = prefs.getInt('farmId');

    if (token != null && farmId != null) {
      if (!mounted) return;
      setState(() {
        _token = token;
        _farmId = farmId;
      });
      await _fetchAnalyticsData();
    } else {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = "Farm ID or Token not found. Please set up farm/login.";
      });
    }
  }

  Future<void> _fetchAnalyticsData() async {
    if (_token == null || _farmId == null) return;

    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final String apiUrl = 'https://devred.pythonanywhere.com/api/analytics/$_farmId/';
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Token $_token'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        setState(() {
          _analyticsData = decodedData;
          _parseAnalyticsData(); // Parse data into state variables
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load analytics (Status: ${response.statusCode}): ${response.body}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  // --- Data Parsing ---
   void _parseAnalyticsData() {
     if (_analyticsData == null) return;

     // Parse Yield Data
     final List<dynamic> yieldList = _analyticsData!['yield_increase'] ?? [];
     _yieldData = yieldList.map((item) => YieldData.fromJson(item)).toList();

      // Parse Cost/Profit Data
     final List<dynamic> costList = _analyticsData!['cost_profit_breakdown'] ?? [];
      // Define colors for the pie chart slices here or use the helper in PieChart widget
      final List<Color> pieColors = [Colors.blueAccent, Colors.greenAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.cyan, Colors.redAccent];
      _costProfitData = costList.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> item = entry.value;
          return CostProfitData.fromJson(item, pieColors[index % pieColors.length]); // Assign color
      }).toList();


      // Parse Water Usage
      final Map<String, dynamic> waterData = _analyticsData!['water_usage'] ?? {};
      _waterUsageValue = (waterData['value'] is String)
          ? (double.tryParse(waterData['value']) ?? 0.0)
          : ((waterData['value'] ?? 0.0) as num).toDouble();
       _waterUsageDescription = waterData['description'] ?? "N/A";


     // Parse Carbon Footprint
     final Map<String, dynamic> carbonData = _analyticsData!['carbon_footprint'] ?? {};
     _carbonFootprintValue = carbonData['value'] ?? "--"; // Keep as string
     _carbonFootprintDescription = carbonData['description'] ?? "N/A";

     // Parse Recommendations
      final List<dynamic> recList = _analyticsData!['personalized_recommendations'] ?? [];
      // Ensure elements are strings
      _recommendations = recList.map((item) => item.toString()).toList();

   }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.onPageChange(0);
          },
        ),
        title: const Column( crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farm Analytics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Your farm performance at a glance',
          style: TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ],),
        actions: [
           // Refresh Button
          IconButton(
             tooltip: "Refresh Analytics",
            onPressed: _isLoading ? null : _loadPrerequisitesAndFetch, // Call reload
            icon: const Icon(Icons.refresh_outlined),
          ),
          // Removed Save button as it's display only
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.save_alt_outlined),
          // ),
        ],
        backgroundColor: AppColors.background,
      ),
      body: _buildBody(), // Use helper for body
    );
  }

  // --- Body Builder ---
  Widget _buildBody() {
     if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: $_errorMessage',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center)));
    }

     if (_analyticsData == null) {
      return const Center(child: Text('No analytics data available.', style: TextStyle(color: AppColors.grey)));
    }

    // --- Data Loaded - Build UI ---
     return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             // Key Metrics (Now dynamic if needed, or keep static titles)
            // Example: Displaying water/carbon textually here too
            _buildKeyMetricsSection(), // Extracted to helper
            const SizedBox(height: 16),

            // --- Charts ---
             BarGraph(yieldDataList: _yieldData), // Pass parsed data
            const SizedBox(height: 16),
             PieChart(costProfitList: _costProfitData), // Pass parsed data
            const SizedBox(height: 16.0),
             RadialBarChart( // Pass parsed data
               waterUsageValue: _waterUsageValue,
               waterUsageDescription: _waterUsageDescription,
               carbonFootprintValue: _carbonFootprintValue,
               carbonFootprintDescription: _carbonFootprintDescription,
             ),
            const SizedBox(height: 16.0),

            // --- Recommendations ---
            const Text(
              'Personalized Recommendations',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0), // Reduced spacing
             if (_recommendations.isEmpty)
                const Text('No specific recommendations available.', style: TextStyle(color: AppColors.grey))
             else
                ListView.builder(
                   physics: const NeverScrollableScrollPhysics(),
                   shrinkWrap: true,
                   itemCount: _recommendations.length,
                   itemBuilder: (context, index) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 10.0), // Spacing between cards
                       child: CustomCard( // Using CustomCard for recommendations
                         title: 'Recommendation #${index + 1}', // Generic title
                         description: _recommendations[index], // The recommendation text
                         width: double.infinity,
                         // Add onTap if needed
                       ),
                     );
                   },
                 ),
             const SizedBox(height: 16.0), // Bottom padding
          ],
        ),
      ),
    );
  }

   // --- Helper for Key Metrics Section ---
   Widget _buildKeyMetricsSection() {
      // You can make these dynamic later if needed, using _analyticsData
     // For now, just showing the water/carbon data as text example
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         const Text('Key Metrics Overview', style: TextStyle(color: AppColors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
         const SizedBox(height: 10),
         _buildMetricRow('Water Use Efficiency', '${_waterUsageValue.toStringAsFixed(0)}%'),
         _buildMetricRow('Carbon Footprint', _carbonFootprintValue),
          // Add Total Yield / Cost-Benefit if available directly in _analyticsData or calculated
          // _buildMetricRow('Total Yield (kg)', _analyticsData?['total_yield'] ?? 'N/A'), // Example
          // _buildMetricRow('Cost-Benefit Ratio', _analyticsData?['cost_benefit_desc'] ?? 'N/A'), // Example
          const SizedBox(height: 10), // Space before env impact section title if used
          // Env impact title removed as data shown in Radial Chart section now
       ],
     );
   }

    Widget _buildMetricRow(String label, String value) {
     return Padding(
       padding: const EdgeInsets.symmetric(vertical: 3.0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
           Text(value, style: const TextStyle(color: AppColors.grey, fontSize: 14, fontStyle: FontStyle.italic)),
         ],
       ),
     );
   }

} // End _AnalyticsState