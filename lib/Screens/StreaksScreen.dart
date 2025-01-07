import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StreaksScreen extends StatefulWidget {
  @override
  _StreaksScreenState createState() => _StreaksScreenState();
}

class _StreaksScreenState extends State<StreaksScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _streakAnimation;
  int _currentStreak = 0; // Initial streak number
  final int _targetStreak = 3; // Dummy target streak for the day

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Define animation to count streak
    _streakAnimation = IntTween(begin: 0, end: _targetStreak).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    )..addListener(() {
      setState(() {
        _currentStreak = _streakAnimation.value;
      });
    });

    // Start animation on screen load
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('1D', 35),
      ChartData('1W', 13),
      ChartData('1M', 34),
      ChartData('1Y', 27),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Streaks'),
        centerTitle: true,
        backgroundColor: Colors.pink[50],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Goal: 3 streak days",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.pink[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Streak Days',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    '$_currentStreak',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        // Refresh Icon
                        IconButton(
                          onPressed: () {
                            // Reset animation and play it again
                            _controller.reset();
                            _controller.forward();
                          },
                          icon: const Icon(Icons.refresh, color: Colors.pink, size: 28),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Streak',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 7),
                        Text(
                          '3',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Last 30 Days +100%',
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(fontSize: 12),
                ),
                series: <CartesianSeries>[
                  SplineSeries<ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    color: Colors.pink,
                    markerSettings: const MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Column(
                  children: [
                    const Text(
                      'Keep it up! You\'re on a roll.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10), // Add spacing between the text and the button
                    SizedBox(
                      width: double.infinity, // Makes the button span the full width of the screen
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your logic here for what happens when "Get Started" is clicked
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xEFA4BDFF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('Get Started'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Routine'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Streaks'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/routine');
          }
        },
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x; // Labels like '1D', '1W', etc.
  final double y;
}
