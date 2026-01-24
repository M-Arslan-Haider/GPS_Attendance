import 'package:flutter/material.dart';
import '../../Utils/daily_work_time_manager.dart'; // Keep your manager import

class DailyTimeCircularCard extends StatelessWidget {
  const DailyTimeCircularCard({super.key});

  final Duration targetWorkTime = const Duration(hours: 8);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, _) {
        return FutureBuilder<DailyWorkTimeResult?>(
          future: DailyWorkTimeManager.getTodayResult(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox();
            }

            final data = snapshot.data!;

            final firstInDuration = _parseTimeString(data.firstIn);
            final lastOutDuration = _parseTimeString(data.lastOut);

            Duration workedDuration = Duration.zero;
            if (firstInDuration != null) {
              if (lastOutDuration != null) {
                workedDuration = lastOutDuration - firstInDuration;
              } else {
                final now = DateTime.now();
                final currentDuration = Duration(
                  hours: now.hour,
                  minutes: now.minute,
                  seconds: now.second,
                );
                workedDuration = currentDuration - firstInDuration;
              }
            }

            final progress = (workedDuration.inSeconds / targetWorkTime.inSeconds).clamp(0.0, 1.0);

            final formattedTotal = _formatDuration(workedDuration);

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Today's Work Time",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 100,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              formattedTotal,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'of 12:00 hrs',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildRow("Clock In", data.firstIn.isEmpty ? "--:--" : data.firstIn),
                  const SizedBox(height: 10),
                  _buildRow("Clock Out", data.lastOut.isEmpty ? "--:--" : data.lastOut),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Duration? _parseTimeString(String time) {
    if (time.isEmpty) return null;

    time = time.trim().toUpperCase();

    try {
      int hours = 0;
      int minutes = 0;
      int seconds = 0;

      if (time.endsWith("AM") || time.endsWith("PM")) {
        final isPM = time.endsWith("PM");
        final t = time.replaceAll(RegExp(r'(AM|PM)'), '').trim();
        final parts = t.split(':').map((e) => int.tryParse(e) ?? 0).toList();
        hours = parts[0];
        minutes = parts.length > 1 ? parts[1] : 0;
        seconds = parts.length > 2 ? parts[2] : 0;

        if (isPM && hours != 12) hours += 12;
        if (!isPM && hours == 12) hours = 0;
      } else {
        final parts = time.split(':').map((e) => int.tryParse(e) ?? 0).toList();
        hours = parts[0];
        minutes = parts.length > 1 ? parts[1] : 0;
        seconds = parts.length > 2 ? parts[2] : 0;
      }

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    } catch (e) {
      print("⚠️ Failed to parse time: $time");
      return null;
    }
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    return "$hours:$minutes";
  }
}