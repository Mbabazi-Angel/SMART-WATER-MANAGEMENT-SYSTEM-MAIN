// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  _AlertsPageState createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<Map<String, String>>> alertsFuture;

  @override
  void initState() {
    super.initState();
    alertsFuture = fetchAlerts(); // Fetch alerts when the page loads
  }

  // Function to fetch alerts from the backend
  Future<List<Map<String, String>>> fetchAlerts() async {
    try {
      final response =
          await http.get(Uri.parse('http://172.20.10.3:5000/alerts'));

      if (response.statusCode == 200) {
        // Parse the response into a list of alerts
        List<dynamic> data = jsonDecode(response.body);
        return data.map((alert) {
          return {
            "type": alert['type']?.toString() ?? '',
            "color": alert['color']?.toString() ?? '',
            "message": alert['message']?.toString() ?? '',
            "timestamp": alert['timestamp']?.toString() ?? '',
          };
        }).toList();
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      return []; // Return an empty list if there's an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.notifications, size: 24),
            SizedBox(width: 8),
            Text(
              "ALERTS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, String>>>(
          future: alertsFuture, // Fetch the alerts
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No alerts available.'));
            } else {
              final alerts = snapshot.data!;

              return ListView.builder(
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final isWaterAlert = alert['type'] == "water";
                  final alertColor = alert['color'] == "yellow"
                      ? Colors.yellow[700]
                      : alert['color'] == "red"
                          ? Colors.red
                          : Colors.green;

                  return AlertCard(
                    icon: isWaterAlert ? Icons.water_drop : Icons.build,
                    color: alertColor!,
                    message: alert['message']!,
                    timestamp: alert['timestamp']!,
                  );
                },
              );
            }
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent, // Set background to blue accent
        selectedItemColor: Colors.white, // White for selected item
        unselectedItemColor:
            Colors.white70, // Slightly faded white for unselected items
        type: BottomNavigationBarType.fixed,
        currentIndex: 1, // Highlight Alerts (index = 1)
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // Stay on Alerts Page
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String timestamp;

  const AlertCard({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  timestamp,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
