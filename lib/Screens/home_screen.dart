import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../ViewModels/attendance_out_view_model.dart';
import '../ViewModels/attendance_view_model.dart';
import '../ViewModels/location_view_model.dart';
import 'HomeScreenComponents/navbar.dart';
import 'HomeScreenComponents/profile_section.dart';
import 'HomeScreenComponents/timer_card.dart' hide LocationViewModel;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {

  // ── Design tokens ──────────────────────────────────────────────────────────
  static const Color _primary     = Color(0xFF1A2B6D);
  static const Color _accent      = Color(0xFF4060FF);
  static const Color _accentLight = Color(0xFFEEF1FF);
  static const Color _surface     = Color(0xFFF5F7FF);
  static const Color _cardBg      = Colors.white;
  static const Color _green       = Color(0xFF22C55E);
  static const Color _red         = Color(0xFFEF4444);

  // ── ViewModels — registered HERE so Get.find() in TimerCard always works ──
  final LocationViewModel      locationVM             = Get.put(LocationViewModel());
  final AttendanceViewModel    attendanceViewModel    = Get.put(AttendanceViewModel());
  final AttendanceOutViewModel attendanceOutViewModel = Get.put(AttendanceOutViewModel());

  // ── State ──────────────────────────────────────────────────────────────────
  String _empName = '';
  String _empId   = '';
  String _empRole = '';

  late final AnimationController _fadeCtrl;
  late final Animation<double>    _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _loadUserData();

    FlutterForegroundTask.startService(
      notificationTitle: 'Shift Active',
      notificationText:  'GPS & time tracking running…',
      callback: startCallback,
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    setState(() {
      _empName = prefs.getString('userName')    ?? 'Employee';
      _empId   = prefs.getString('userId')      ?? '--';
      _empRole = prefs.getString('designation') ?? 'Staff';
    });
  }

  // ──────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: _surface,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 1),
                    TimerCard(),
                    const SizedBox(height: 25),
                    _buildQuickActions(horizontalPadding: 5),

                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions({required double horizontalPadding}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionTile(
                icon: Icons.calendar_month_rounded,
                label: 'Leave',
                onTap: () => Get.to(() => ()),
              ),
              const SizedBox(width: 12),
              _actionTile(
                icon: Icons.task_alt_rounded,
                label: 'Tasks',
                onTap: () => Get.to(() => ()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4354E8).withOpacity(0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBEEFD),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 26,
                  color: const Color(0xFF4354E8),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ─── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFF4354E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft:  Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          // decorative circles
          Positioned(top: -60, right: -40,
              child: _decorCircle(220, 0.06)),
          Positioned(bottom: -30, left: -20,
              child: _decorCircle(140, 0.04)),

          SafeArea(
            child: Column(
              children: [
                Navbar(),
                const SizedBox(height: 4),
                const ProfileSection(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );

  Widget _chip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.white70),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    ),
  );

  // ─── SECTION LABEL ─────────────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4, height: 18,
        decoration: BoxDecoration(
            color: _accent, borderRadius: BorderRadius.circular(2)),
      ),
      const SizedBox(width: 8),
      Text(text,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _primary,
              letterSpacing: 0.4)),
    ],
  );

  // ─── STATS ROW ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Obx(() {
      final inCount     = attendanceViewModel.allAttendance.length;
      final outCount    = attendanceOutViewModel.allAttendanceOut.length;
      final isClockedIn = attendanceViewModel.isClockedIn.value;
      final elapsed     = attendanceViewModel.elapsedTime.value;

      return Row(
        children: [
          _statCard(LucideIcons.logIn,  'Clock-Ins',  '$inCount',  _green),
          const SizedBox(width: 10),
          _statCard(LucideIcons.logOut, 'Clock-Outs', '$outCount', _red),
          const SizedBox(width: 10),
          _statCard(LucideIcons.timer,  'Shift Time',
              isClockedIn ? elapsed : '--:--', _accent),
        ],
      );
    });
  }

  Widget _statCard(IconData icon, String label, String value, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          decoration: BoxDecoration(
            color: _cardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.10),
                blurRadius: 12, offset: const Offset(0, 4))],
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 10),
              Text(value,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );

  // ─── SYNC CARD ─────────────────────────────────────────────────────────────
  Widget _buildSyncCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
            blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(LucideIcons.refreshCw,
                    size: 20, color: _accent),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Sync',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _primary)),
                    SizedBox(height: 2),
                    Text('Records sync automatically when online',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await attendanceViewModel.syncUnposted();
                  await attendanceOutViewModel.syncUnposted();
                  Get.snackbar('✅ Synced', 'All records pushed to server',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: _green,
                      colorText: Colors.white,
                      duration: const Duration(seconds: 2));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Text('Sync Now',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),

          Obx(() {
            final pendIn  = attendanceViewModel.allAttendance
                .where((r) => r.posted == 0).length;
            final pendOut = attendanceOutViewModel.allAttendanceOut
                .where((r) => r.posted == 0).length;
            return Row(
              children: [
                _pendingChip('Pending IN',  pendIn),
                const SizedBox(width: 10),
                _pendingChip('Pending OUT', pendOut),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _pendingChip(String label, int count) {
    final color = count > 0 ? _red : _green;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ─── LOCATION CARD ─────────────────────────────────────────────────────────
  Widget _buildLocationCard() {
    return Obx(() {
      final lat     = locationVM.globalLatitude1.value;
      final lng     = locationVM.globalLongitude1.value;
      final address = locationVM.shopAddress.value;
      final hasLoc  = lat != 0.0 || lng != 0.0;
      final color   = hasLoc ? _green : Colors.orange;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
              blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(LucideIcons.mapPin, size: 22, color: color),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasLoc ? 'Location Active' : 'Waiting for GPS…',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: color),
                  ),
                  const SizedBox(height: 4),
                  if (hasLoc) ...[
                    Text(
                      address.isNotEmpty ? address : 'Fetching address…',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                          fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                  ] else
                    const Text(
                      'Enable location services to track your shift',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),

            // refresh button
            GestureDetector(
              onTap: () => locationVM.saveCurrentLocation(),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                    color: _accentLight,
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(LucideIcons.refreshCw,
                    size: 16, color: _accent),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─── HELPERS ───────────────────────────────────────────────────────────────
  void _showClockInRequiredDialog() {
    Get.defaultDialog(
      title: 'Clock In Required',
      titleStyle: const TextStyle(
          fontWeight: FontWeight.w700, color: _primary),
      middleText: 'Please start your shift timer first.',
      middleTextStyle: TextStyle(color: Colors.grey.shade600),
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: _accent,
      radius: 16,
      onConfirm: Get.back,
    );
  }
}

// ── Foreground task handler ───────────────────────────────────────────────────
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  Future<void> onRepeatEvent(DateTime timestamp) async {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool restart) async {}
}