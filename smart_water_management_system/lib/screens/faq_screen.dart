import 'package:flutter/material.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  final List<Map<String, String>> faqs = [
    {
      "question": "How do I monitor my water usage?",
      "answer": "You can monitor your usage on the home page under the usage stats section."
    },
    {
      "question": "How are the water costs calculated?",
      "answer": "Costs are based on the volume of water used and the current pricing rate."
    },
    {
      "question": "Can I download my water usage breakdown?",
      "answer": "Yes, click on the download button in the daily breakdown section."
    },
    {
      "question": "What should I do if I detect a leak?",
      "answer": "Use the report leakage option in the settings page to provide details about the leak."
    },
    {
      "question": "How can I change my alert preferences?",
      "answer": "Go to the settings page and toggle between push notifications and SMS alerts."
    },
    {
      "question": "What happens during a water shortage?",
      "answer": "You will receive an alert, and the app will provide conservation tips to manage your usage."
    },
  ];

  List<Map<String, String>> filteredFaqs = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    filteredFaqs = faqs; // Initialize with all FAQs
  }

  void updateSearch(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredFaqs = faqs
          .where((faq) =>
              faq["question"]!.toLowerCase().contains(searchQuery) ||
              faq["answer"]!.toLowerCase().contains(searchQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 24),
            SizedBox(width: 8),
            Text(
              "FAQ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: updateSearch,
            ),
            const SizedBox(height: 20),
            // FAQ List
            Expanded(
              child: ListView.builder(
                itemCount: filteredFaqs.length,
                itemBuilder: (context, index) {
                  return ExpansionTile(
                    title: Text(
                      filteredFaqs[index]["question"]!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          filteredFaqs[index]["answer"]!,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
