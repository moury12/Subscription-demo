import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../progress/controllers/burn_history_controller.dart';

class BurnHistoryScreen extends StatefulWidget {
  const BurnHistoryScreen({super.key});

  @override
  State<BurnHistoryScreen> createState() => _BurnHistoryScreenState();
}

class _BurnHistoryScreenState extends State<BurnHistoryScreen> {
  bool _isWeekly = false;
  final BurnHistoryController _controller = BurnHistoryController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_update);
  }

  @override
  void dispose() {
    _controller.removeListener(_update);
    super.dispose();
  }

  void _update() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Burn History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              'TRACK YOUR EXTRA EFFORT',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Daily/Weekly Toggle
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF161616),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleButton('Daily', !_isWeekly),
                  ),
                  Expanded(
                    child: _buildToggleButton('Weekly', _isWeekly),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    iconColor: const Color(0xFFFB923C),
                    label: _isWeekly ? 'WEEKLY BURN' : 'TOTAL BURNED',
                    value: _isWeekly 
                      ? '${_controller.history.fold(0.0, (sum, l) => sum + l.caloriesBurned).toStringAsFixed(1)} kcal'
                      : '${_controller.totalBurnedToday.toStringAsFixed(1)} kcal',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.query_stats,
                    iconColor: const Color(0xFF60A5FA),
                    label: _isWeekly ? 'TOTAL ACTIVITIES' : 'ACTIVITIES',
                    value: _isWeekly 
                      ? '${_controller.history.length}'
                      : '${_controller.activityCountToday}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Recent Logs Section
            const Row(
              children: [
                Icon(Icons.access_time, color: Colors.white38, size: 18),
                SizedBox(width: 8),
                Text(
                  'RECENT LOGS',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._controller.history.map((log) {
              final String formattedDate = DateFormat('h:mm a • d/M/yyyy').format(log.date);
              return _buildLogCard(log.activity, formattedDate, log.caloriesBurned.toStringAsFixed(1));
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isWeekly = label == 'Weekly'),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white38,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(String title, String subtitle, String kcal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFB923C).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_fire_department, color: Color(0xFFFB923C), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-$kcal',
                style: const TextStyle(
                  color: Color(0xFFFB923C),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'KCAL',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
