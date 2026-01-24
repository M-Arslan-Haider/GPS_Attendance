import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class DailyWorkTimeResult {
  final String firstIn;
  final String lastOut;
  final String totalTime;
  final Duration totalDuration;

  DailyWorkTimeResult({
    required this.firstIn,
    required this.lastOut,
    required this.totalTime,
    required this.totalDuration,
  });
}

class DailyWorkTimeManager {
  static const _dateKey = "work_date";
  static const _inListKey = "clock_in_list";
  static const _outListKey = "clock_out_list";
  static const _totalSecondsKey = "total_work_seconds";
  static const _lastInKey = "last_clock_in";

  /// Call on Clock-In
  static Future<void> recordClockIn(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);

    prefs.setString(_lastInKey, time.toIso8601String());

    final list = prefs.getStringList(_inListKey) ?? [];
    list.add(time.toIso8601String());
    await prefs.setStringList(_inListKey, list);
  }

  /// Call on Clock-Out
  static Future<void> recordClockOut(DateTime outTime) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);

    final lastIn = prefs.getString(_lastInKey);
    if (lastIn == null) return;

    final inTime = DateTime.parse(lastIn);
    final seconds = outTime.difference(inTime).inSeconds;

    final total = (prefs.getInt(_totalSecondsKey) ?? 0) + seconds;
    prefs.setInt(_totalSecondsKey, total);

    final outs = prefs.getStringList(_outListKey) ?? [];
    outs.add(outTime.toIso8601String());
    await prefs.setStringList(_outListKey, outs);
  }

  /// Read result
  static Future<DailyWorkTimeResult?> getTodayResult() async {
    final prefs = await SharedPreferences.getInstance();
    await _resetIfNewDay(prefs);

    final ins = prefs.getStringList(_inListKey) ?? [];
    final outs = prefs.getStringList(_outListKey) ?? [];
    final totalSeconds = prefs.getInt(_totalSecondsKey) ?? 0;

    if (ins.isEmpty || outs.isEmpty) return null;

    final firstIn = DateTime.parse(ins.first);
    final lastOut = DateTime.parse(outs.last);

    return DailyWorkTimeResult(
      firstIn: DateFormat("hh:mm a").format(firstIn),
      lastOut: DateFormat("hh:mm a").format(lastOut),
      totalTime: _format(totalSeconds),
      totalDuration: Duration(seconds: totalSeconds),
    );
  }

  static Future<void> _resetIfNewDay(SharedPreferences prefs) async {
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final saved = prefs.getString(_dateKey);

    if (saved != today) {
      prefs.setString(_dateKey, today);
      prefs.remove(_inListKey);
      prefs.remove(_outListKey);
      prefs.remove(_totalSecondsKey);
      prefs.remove(_lastInKey);
    }
  }

  static String _format(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    return "${h}h ${m}m";
  }
}
