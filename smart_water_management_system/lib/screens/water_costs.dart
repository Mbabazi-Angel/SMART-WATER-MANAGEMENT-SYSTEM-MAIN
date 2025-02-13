import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class WaterCostsPage extends StatefulWidget {
  const WaterCostsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WaterCostsPageState createState() => _WaterCostsPageState();
}

class _WaterCostsPageState extends State<WaterCostsPage> {
  String selectedMonth = DateFormat.MMMM().format(DateTime.now());
  final Map<String, int> monthlyCosts = {
    'January': 48000,
    'February': 46000,
    'March': 52000,
    'April': 50000,
    'December': 30000,
    // Add more months if needed
  };
  List<Map<String, String>> costDetails = [
    {"date": "19/12/24", "usage": "50L", "cost": "UGX 500"},
    {"date": "18/12/24", "usage": "60L", "cost": "UGX 600"},
    {"date": "17/12/24", "usage": "70L", "cost": "UGX 900"},
    {"date": "16/12/24", "usage": "60L", "cost": "UGX 200"},
    {"date": "15/12/24", "usage": "90L", "cost": "UGX 600"},
    {"date": "14/12/24", "usage": "20L", "cost": "UGX 300"},
    {"date": "13/12/24", "usage": "70L", "cost": "UGX 900"},
    {"date": "12/12/24", "usage": "20L", "cost": "UGX 100"},
    {"date": "11/12/24", "usage": "80L", "cost": "UGX 500"}
  ];

  // Dynamic costs
  double dailyCost = 1500;
  double lastWeekCost = 10000;
  double thisWeekCost = 50000;

  @override
  void initState() {
    super.initState();
    updateCosts(); // Calculate costs dynamically
  }

  void updateCosts() {
    // Example dynamic calculations
    setState(() {
      dailyCost = 1500 + (DateTime.now().day % 5) * 100;
      lastWeekCost = 10000 + (DateTime.now().weekday * 50);
      thisWeekCost = 50000 + (DateTime.now().weekday * 100);
    });
  }

  int getMonthlyCost(String month) {
    return monthlyCosts.containsKey(month) ? monthlyCosts[month]! : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          "WATER COSTS",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Monthly Summary
              Container(
                width: double.infinity, // Spans the full row
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "Estimated Cost for $selectedMonth",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'UGX ${getMonthlyCost(selectedMonth)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Daily, Weekly, Costs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _costTile("Today", "UGX $dailyCost"),
                  _costTile("Last Week", "UGX $lastWeekCost"),
                  _costTile("This Week", "UGX $thisWeekCost"),
                ],
              ),
              const SizedBox(height: 20),
              // Details Table Header with Download Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Daily Breakdown",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Implement download functionality
                    },
                    icon: const Icon(Icons.download),
                    color: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Details Table
              Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  // Table Header
                  TableRow(
                    children: [
                      _tableHeader("Date"),
                      _tableHeader("Usage"),
                      _tableHeader("Cost"),
                    ],
                  ),
                  // Table Rows
                  ...costDetails.map((detail) {
                    return TableRow(
                      children: [
                        _tableCell(detail["date"]!),
                        _tableCell(detail["usage"]!),
                        _tableCell(detail["cost"]!),
                      ],
                    );
                    // ignore: unnecessary_to_list_in_spreads
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _costTile(String title, String cost) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            cost,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white, // White text
        ),
      ),
    );
  }
}
