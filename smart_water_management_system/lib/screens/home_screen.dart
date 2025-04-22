// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:sensors_plus/sensors_plus.dart';

/// A widget that draws a dashed horizontal line.
/// You can adjust dashWidth, dashSpace, and height as needed.
class DashedLine extends StatelessWidget {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double height;
  final double width;

  const DashedLine({
    super.key,
    required this.color,
    this.dashWidth = 8,
    this.dashSpace = 4,
    this.height = 3,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _DashedLinePainter(
          color: color, dashWidth: dashWidth, dashSpace: dashSpace),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  _DashedLinePainter({
    required this.color,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.height;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A custom widget that shows an animated liquid fill inside a circle.
class LiquidFillWidget extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Widget center;
  final double tiltAngle; // in radians

  const LiquidFillWidget({
    super.key,
    required this.progress,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.center,
    required this.tiltAngle,
  });

  @override
  _LiquidFillWidgetState createState() => _LiquidFillWidgetState();
}

class _LiquidFillWidgetState extends State<LiquidFillWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // The controller continuously animates the wave phase.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild the CustomPaint whenever the animation ticks.
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return CustomPaint(
          painter: LiquidFillPainter(
            progress: widget.progress,
            wavePhase: _controller.value,
            backgroundColor: widget.backgroundColor,
            borderColor: widget.borderColor,
            borderWidth: widget.borderWidth,
            tiltAngle: widget.tiltAngle,
          ),
          child: child,
        );
      },
      child: widget.center,
    );
  }
}

/// The CustomPainter that draws the animated liquid fill.
class LiquidFillPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double tiltAngle; // in radians

  LiquidFillPainter({
    required this.progress,
    required this.wavePhase,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderWidth,
    required this.tiltAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Determine the center and radius of the circle.
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Create a circular path for the container.
    final circlePath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));

    // Draw a shadow behind the circle.
    canvas.drawShadow(circlePath, Colors.black.withOpacity(0.4), 10.0, true);

    // Draw the circular background.
    final bgPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(center, radius, bgPaint);

    // Clip to the circle.
    final clipPath = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.save();
    canvas.clipPath(clipPath);

    // Compute the water level position.
    final waterLevel = size.height * (1 - progress);

    // Save canvas state for rotation.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw the sine wave.
    final wavePath = Path();
    wavePath.moveTo(0, size.height);
    wavePath.lineTo(0, waterLevel);
    const waveAmplitude = 8.0;
    final waveLength = size.width;
    for (double x = 0; x <= size.width; x++) {
      double y =
          waveAmplitude * sin((2 * pi / waveLength) * x + wavePhase * 2 * pi) +
              waterLevel;
      wavePath.lineTo(x, y);
    }
    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.lightBlueAccent, Colors.blue],
    );
    final rect = Rect.fromCircle(center: center, radius: radius);
    final wavePaint = Paint()..shader = gradient.createShader(rect);
    canvas.drawPath(wavePath, wavePaint);
    canvas.restore();
    canvas.restore();

    // Draw the border.
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant LiquidFillPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.tiltAngle != tiltAngle;
  }
}

/// A helper widget for creating legend items.
class _LegendItem {
  final Color color;
  final String title;
  final bool isDashed;

  _LegendItem(this.isDashed, {required this.color, required this.title});
}

/// A widget to display a pie chart with a legend.
class DailyMetricsPieChart extends StatelessWidget {
  final double dailyFlow;
  final double dailyPressure;
  final double dailyLevel;

  const DailyMetricsPieChart({
    super.key,
    required this.dailyFlow,
    required this.dailyPressure,
    required this.dailyLevel,
  });

  @override
  Widget build(BuildContext context) {
    final total = dailyFlow + dailyPressure + dailyLevel;
    double levelPercent = total > 0 ? (dailyLevel / total * 100) : 0;
    double flowPercent = total > 0 ? (dailyFlow / total * 100) : 0;
    double pressurePercent = total > 0 ? (dailyPressure / total * 100) : 0;

    final sections = <PieChartSectionData>[
      PieChartSectionData(
        color: Colors.blue,
        value: dailyLevel,
        title: '${levelPercent.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.tealAccent,
        value: dailyFlow,
        title: '${flowPercent.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      PieChartSectionData(
        color: Colors.orangeAccent,
        value: dailyPressure,
        title: '${pressurePercent.toStringAsFixed(1)}%',
        radius: 50,
        titleStyle: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    ];

    final legendItems = [
      _LegendItem(false, color: Colors.blue, title: "Water Level"),
      _LegendItem(false, color: Colors.tealAccent, title: "Water Flow"),
      _LegendItem(false, color: Colors.orangeAccent, title: "Water Pressure"),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Daily Metrics Distribution",
          style: GoogleFonts.roboto(
            color: Colors.white70,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: legendItems
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: item.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.title,
                            style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A widget that displays a line chart comparing water level for this week versus last week.
/// The solid blue line represents this week's daily averages, and the dotted blue line represents last week's.
/// Below the chart is a legend indicating which style represents which period.
class WeekComparisonLineChart extends StatelessWidget {
  final List<FlSpot> thisWeekSpots;
  final List<FlSpot> lastWeekSpots;

  const WeekComparisonLineChart({
    super.key,
    required this.thisWeekSpots,
    required this.lastWeekSpots,
  });

  @override
  Widget build(BuildContext context) {
    const double maxX = 6; // x-axis: 0 (Mon) to 6 (Sun)
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          height: 300,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: true),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: 10,
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 35,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const dayLabels = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun'
                      ];
                      int index = value.toInt();
                      if (index >= 0 && index < dayLabels.length) {
                        return Text(dayLabels[index],
                            style: GoogleFonts.roboto(
                              color: Colors.white70,
                              fontSize: 10,
                            ));
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: true),
              minX: 0,
              maxX: maxX,
              minY: 0,
              maxY: 100,
              lineBarsData: [
                // This week's water level (solid blue line)
                LineChartBarData(
                  spots: thisWeekSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                ),
                // Last week's water level (dotted blue line)
                LineChartBarData(
                  spots: lastWeekSpots,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  dashArray: [8, 4],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Legend for the line chart.
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Solid line legend for Current Week.
            Row(
              children: [
                Container(
                  width: 40,
                  height: 3,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                Text(
                  "Current Week",
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            // Dotted line legend for Last Week.
            Row(
              children: [
                const DashedLine(
                  color: Colors.blue,
                  width: 40,
                  dashWidth: 8,
                  dashSpace: 4,
                  height: 3,
                ),
                const SizedBox(width: 8),
                Text(
                  "Last Week",
                  style: GoogleFonts.roboto(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// The HomeScreen fetches sensor data and displays them in a dashboard.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sensor Data (default values)
  int unreadAlerts = 0;
  double waterLevel = 0; // 0-100%
  int todayUsage = 0;
  int thisWeekUsage = 0;
  int lastWeekUsage = 0;
  double waterFlow = 0;
  double waterPressure = 0;
  String sensorId = 'Unknown';
  String conservationTip = "Fix leaking taps to save water!";

  // Daily aggregated metrics for the pie chart.
  double dailyWaterFlow = 0;
  double dailyWaterPressure = 0;
  double dailyWaterLevel = 0;

  // Weekly water level trends.
  List<FlSpot> thisWeekLevelSpots = [];
  List<FlSpot> lastWeekLevelSpots = [];

  // List to hold all sensor data.
  List<dynamic> sensorDataList = [];

  Timer? _timer;
  double _tiltAngle = 0;
  StreamSubscription? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    fetchData();
    // Update sensor data every 5 seconds (for demo).
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchData();
    });
    // Listen to accelerometer events.
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double newTilt = event.x / 20;
      if ((newTilt - _tiltAngle).abs() > 0.001) {
        setState(() {
          _tiltAngle = newTilt;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      // Replace with your API endpoint.
      final response =
          await http.get(Uri.parse('http://172.20.10.3:5000/sensor-data'));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        // Ensure we have a list of data.
        List<dynamic> dataList = [];
        if (responseData is List) {
          dataList = responseData;
          sensorDataList = dataList;
        } else {
          dataList = [responseData];
          sensorDataList = dataList;
        }

        int sumToday = 0;
        int sumThisWeek = 0;
        int sumLastWeek = 0;

        double sumFlow = 0;
        double sumPressure = 0;
        double sumLevel = 0;
        int countFlow = 0;
        int countPressure = 0;
        int countLevel = 0;

        DateTime now = DateTime.now();
        // Assuming week starts on Monday.
        DateTime startOfWeek = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - 1));
        DateTime endOfWeek = startOfWeek.add(const Duration(days: 7));
        DateTime startOfLastWeek =
            startOfWeek.subtract(const Duration(days: 7));
        DateTime endOfLastWeek = startOfWeek;

        // For weekly water level aggregation.
        Map<int, List<double>> thisWeekLevels = {};
        Map<int, List<double>> lastWeekLevels = {};

        for (var row in dataList) {
          DateTime ts = DateTime.tryParse(row['timestamp'] ?? '') ?? now;
          int usage = row['water_usage'] is int ? row['water_usage'] : 0;

          // Current day metrics.
          if (ts.year == now.year &&
              ts.month == now.month &&
              ts.day == now.day) {
            sumToday += usage;
            if (row['water_flow'] != null) {
              double flowValue =
                  (row['water_flow'] is num ? row['water_flow'].toDouble() : 0);
              sumFlow += flowValue;
              countFlow++;
            }
            if (row['water_pressure'] != null) {
              double pressureValue = (row['water_pressure'] is num
                  ? row['water_pressure'].toDouble()
                  : 0);
              sumPressure += pressureValue;
              countPressure++;
            }
            if (row['water_level'] != null) {
              double levelValue = (row['water_level'] is num
                  ? row['water_level'].toDouble()
                  : 0);
              sumLevel += levelValue;
              countLevel++;
            }
          }
          if (ts.isAfter(startOfWeek) && ts.isBefore(endOfWeek)) {
            sumThisWeek += usage;
            if (row['water_level'] != null) {
              double levelValue = (row['water_level'] is num
                  ? row['water_level'].toDouble()
                  : 0);
              int day = ts.weekday; // 1 (Mon) to 7 (Sun)
              thisWeekLevels[day] = (thisWeekLevels[day] ?? [])
                ..add(levelValue);
            }
          } else if (ts.isAfter(startOfLastWeek) &&
              ts.isBefore(endOfLastWeek)) {
            sumLastWeek += usage;
            if (row['water_level'] != null) {
              double levelValue = (row['water_level'] is num
                  ? row['water_level'].toDouble()
                  : 0);
              int day = ts.weekday;
              lastWeekLevels[day] = (lastWeekLevels[day] ?? [])
                ..add(levelValue);
            }
          }
        }

        todayUsage = sumToday;
        thisWeekUsage = sumThisWeek;
        lastWeekUsage = sumLastWeek;
        dailyWaterFlow = countFlow > 0 ? sumFlow : 0;
        dailyWaterPressure = countPressure > 0 ? sumPressure : 0;
        dailyWaterLevel = countLevel > 0 ? (sumLevel / countLevel) : waterLevel;

        // Fetch sensor data for sensor_10.
        final sensor10 = dataList.firstWhere(
            (row) => row['sensor_id'] == 'sensor_10',
            orElse: () => null);
        if (sensor10 != null) {
          waterLevel = sensor10['water_level']?.toDouble() ?? 0;
          waterFlow = sensor10['water_flow']?.toDouble() ?? 0;
          waterPressure = sensor10['water_pressure']?.toDouble() ?? 0;
          sensorId = sensor10['sensor_id'] ?? 'Unknown';
        }

        // Compute daily averages for water level.
        List<FlSpot> thisWeekSpots = [];
        List<FlSpot> lastWeekSpots = [];
        // Days of week: Monday (1) to Sunday (7), x-axis: 0 to 6.
        for (int day = 1; day <= 7; day++) {
          double x = (day - 1).toDouble();
          double thisAvg = 0;
          double lastAvg = 0;
          if (thisWeekLevels.containsKey(day)) {
            List<double> values = thisWeekLevels[day]!;
            thisAvg = values.reduce((a, b) => a + b) / values.length;
          }
          if (lastWeekLevels.containsKey(day)) {
            List<double> values = lastWeekLevels[day]!;
            lastAvg = values.reduce((a, b) => a + b) / values.length;
          }
          thisWeekSpots.add(FlSpot(x, thisAvg));
          lastWeekSpots.add(FlSpot(x, lastAvg));
        }

        setState(() {
          thisWeekLevelSpots = thisWeekSpots;
          lastWeekLevelSpots = lastWeekSpots;
        });
      } else {
        throw Exception('Failed to load sensor data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = (waterLevel / 100).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "DASHBOARD",
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  Navigator.pushNamed(context, '/alerts');
                },
              ),
              if (unreadAlerts > 0)
                Positioned(
                  right: 11,
                  top: 11,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      '$unreadAlerts',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.blueGrey.shade900,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top section: Liquid fill gauge and notice.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Water Level",
                    style: GoogleFonts.roboto(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        height: 180,
                        width: 180,
                        child: LiquidFillWidget(
                          progress: progress,
                          backgroundColor: Colors.grey[300]!,
                          borderColor: Colors.white,
                          borderWidth: 2.0,
                          tiltAngle: _tiltAngle,
                          center: Center(
                            child: Text(
                              '${waterLevel.toInt()}%',
                              style: GoogleFonts.roboto(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            waterLevel > 50
                                ? "Alert: High water level detected. Check for overflows or leaks."
                                : "Notice: Water level is low. Please consider conservation measures.",
                            style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              // Sensor and usage metrics.
              GridView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                children: [
                  _buildSensorCard(
                    title: "Water Flow",
                    value: "${waterFlow.toStringAsFixed(2)} L/min",
                    icon: Icons.water_drop,
                    backgroundColor: Colors.tealAccent,
                    iconColor: Colors.teal[800]!,
                  ),
                  _buildSensorCard(
                    title: "Water Pressure",
                    value: "${waterPressure.toStringAsFixed(2)} bar",
                    icon: Icons.speed,
                    backgroundColor: Colors.orangeAccent,
                    iconColor: Colors.deepOrange[800]!,
                  ),
                  _buildUsageCard("Today", todayUsage),
                  _buildUsageCard("This Week", thisWeekUsage),
                  _buildUsageCard("Last Week", lastWeekUsage),
                  _buildUsageCard("Monthly", (thisWeekUsage * 4)),
                ],
              ),
              const SizedBox(height: 30),
              // Pie chart with legend.
              DailyMetricsPieChart(
                dailyFlow: dailyWaterFlow,
                dailyPressure: dailyWaterPressure,
                dailyLevel: dailyWaterLevel,
              ),
              const SizedBox(height: 30),
              // Weekly comparison line chart.
              WeekComparisonLineChart(
                thisWeekSpots: thisWeekLevelSpots,
                lastWeekSpots: lastWeekLevelSpots,
              ),
              const SizedBox(height: 30),
              // Action buttons.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton("FAQ", Icons.help, () {
                    Navigator.pushNamed(context, '/FAQ');
                  }),
                  _buildActionButton("Share App", Icons.share, () {
                    // Implement share functionality.
                  }),
                  _buildActionButton("Bills", Icons.receipt, () {
                    Navigator.pushNamed(context, '/costs');
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueAccent, // Set background to blue accent
        selectedItemColor: Colors.white, // White for selected item
        unselectedItemColor:
            Colors.white70, // Slightly faded white for unselected items
        type: BottomNavigationBarType.fixed,
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
            Navigator.pushNamed(context, '/alerts');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          } else if (index == 3) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildUsageCard(String label, int usage) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade400,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$usage Gallons',
            style: GoogleFonts.roboto(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        minimumSize: const Size(120, 45),
        textStyle: GoogleFonts.roboto(fontSize: 13),
      ),
    );
  }

  Widget _buildSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}
