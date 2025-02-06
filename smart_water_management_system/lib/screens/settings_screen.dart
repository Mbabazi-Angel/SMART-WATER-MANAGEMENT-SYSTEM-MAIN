import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool pushNotifications = false; // Initial state
  bool smsAlerts = false; // Initial state

  bool showFeedback = false; // Default is false
  bool showReportLeakage = false; // Default is false

  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController leakageController = TextEditingController();

  // Function to submit feedback to the server
  Future<void> submitFeedback(String feedback) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.126.3.32:5000/submit-feedback'), // Your server's URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'content': feedback}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Feedback submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting feedback')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to the server')),
      );
    }
  }

  // Function to submit leakage report to the server
  Future<void> submitLeakageReport(String description) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://10.126.3.32:5000/submit-leakage-report'), // Your server's URL
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'description': description}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Leakage report submitted successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error submitting leakage report')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error connecting to the server')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSwitchValues();
  }

  // Load the switch values from SharedPreferences
  Future<void> _loadSwitchValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('pushNotifications') ?? false;
      smsAlerts = prefs.getBool('smsAlerts') ?? false;
    });
  }

  // Save the switch values to SharedPreferences
  Future<void> _saveSwitchValues() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('pushNotifications', pushNotifications);
    prefs.setBool('smsAlerts', smsAlerts);
  }

  // Function to launch a URL
  // Launch phone call
  void _launchPhone() async {
    const phoneUrl = 'tel:+1234567890';
    if (await canLaunch(phoneUrl)) {
      await launch(phoneUrl);
    } else {
      debugPrint("Could not launch $phoneUrl");
    }
  }

  void _launchEmail() async {
    const emailUrl = 'mailto:support@example.com';
    if (await canLaunch(emailUrl)) {
      await launch(emailUrl);
    } else {
      debugPrint("Could not launch $emailUrl");
    }
  }

  void _launchSMS() async {
    const smsUrl = 'sms:+1234567890';
    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    } else {
      debugPrint("Could not launch $smsUrl");
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
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 20),
            SizedBox(width: 8),
            Text(
              "SETTINGS",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Push Notifications & SMS Alerts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Push Notifications",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: pushNotifications,
                    onChanged: (value) {
                      setState(() {
                        pushNotifications = value;
                      });
                      _saveSwitchValues();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "SMS Alerts",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Switch(
                    value: smsAlerts,
                    onChanged: (value) {
                      setState(() {
                        smsAlerts = value;
                      });
                      _saveSwitchValues();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Language Settings
              const Text(
                "Language Settings",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                hint: const Text('Choose Preferred Language'),
                items: const [
                  DropdownMenuItem(value: 'English', child: Text("English")),
                  DropdownMenuItem(value: 'Swahili', child: Text("Swahili")),
                  DropdownMenuItem(value: 'French', child: Text("French")),
                  DropdownMenuItem(value: 'Spanish', child: Text("Spanish")),
                  DropdownMenuItem(value: 'Arabic', child: Text("Arabic")),
                ],
                onChanged: (value) {},
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              // Feedback
              GestureDetector(
                onTap: () {
                  setState(() {
                    showFeedback = !showFeedback;
                    if (!showFeedback) {
                      feedbackController
                          .clear(); // Clear feedback when closing the form
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Feedback",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              if (showFeedback)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: feedbackController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Write your feedback here...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        submitFeedback(
                            feedbackController.text); // Submit feedback
                        setState(() {
                          showFeedback =
                              false; // Close feedback form after submission
                          feedbackController
                              .clear(); // Clear the feedback text field
                        });
                      },
                      child: const Text("Submit Feedback"),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              // Report Leakage
              GestureDetector(
                onTap: () {
                  setState(() {
                    showReportLeakage = !showReportLeakage;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      "Report Leakage",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              if (showReportLeakage)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    TextField(
                      controller: leakageController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Provide necessary specifications...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        submitLeakageReport(leakageController.text);
                        setState(() {
                          showReportLeakage = false;
                          leakageController.clear();
                        });
                      },
                      child: const Text("Submit Report"),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              // Help and Support
              const Text(
                "Help & Support",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  ListTile(
                    title: const Text("Call Us"),
                    leading: const Icon(Icons.call),
                    onTap: _launchPhone,
                  ),
                  ListTile(
                    title: const Text("Email Us"),
                    leading: const Icon(Icons.email),
                    onTap: _launchEmail,
                  ),
                  ListTile(
                    title: const Text("Text Support"),
                    leading: const Icon(Icons.message),
                    onTap: _launchSMS,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Reset Account
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle account reset
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    elevation: 5,
                    shadowColor: Colors.black,
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    "Reset Account",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Alerts"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
        currentIndex: 2, // Highlight Settings
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushNamed(context, '/alerts');
          } else if (index == 2) {
            // Stay on Settings Page
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
