
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Databases/dp_helper.dart';
import '../../Databases/util.dart';
import '../../Utils/ForceUpdateService.dart';
import '../../ViewModels/add_shop_view_model.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../ViewModels/attendance_view_model.dart';
import '../../ViewModels/location_view_model.dart';
import '../../ViewModels/update_function_view_model.dart';
import '../HomeScreenComponents/timer_card.dart';
import '../HomeScreenComponents/profile_section.dart';
import 'NSMOrderDetails/nsm_order_details_screen.dart';
import 'NSM_ShopVisit.dart';
import 'NSM_bookerbookingdetails.dart';
import 'nsm_bookingStatus.dart';
import 'NSM LOCATIONS/nsm_location_navigation.dart';
import 'nsm_shopdetails.dart';
import '../../main.dart' hide checkForUpdate;
import 'package:permission_handler/permission_handler.dart'
    show Permission, openAppSettings, ServiceStatus;

class NSMHomepage extends StatefulWidget {
  const NSMHomepage({super.key});

  @override
  NSMHomepageState createState() => NSMHomepageState();
}

class NSMHomepageState extends State<NSMHomepage> {
  final DBHelper dbHelper = DBHelper();
  late final addShopViewModel = Get.put(AddShopViewModel());
  late final attendanceViewModel = Get.put(AttendanceViewModel());
  late final attendanceOutViewModel = Get.put(AttendanceOutViewModel());
  late StreamSubscription<ServiceStatus> locationServiceStatusStream;


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateService.check(context);
    });

    Get.put(UpdateFunctionViewModel());
    Get.put(LocationViewModel());
    addShopViewModel.fetchAllAddShop();
    attendanceViewModel.fetchAllAttendance();
    attendanceOutViewModel.fetchAllAttendanceOut();
    _retrieveSavedValues();
  }


  // @override
  // void initState() {
  //   super.initState();
  //   Get.put(UpdateFunctionViewModel());
  //   Get.put(LocationViewModel());
  //   addShopViewModel.fetchAllAddShop();
  //   attendanceViewModel.fetchAllAttendance();
  //   attendanceOutViewModel.fetchAllAttendanceOut();
  //   _retrieveSavedValues();
  //   checkForUpdate();
  // }

  @override
  void dispose() {
    locationServiceStatusStream.cancel();
    super.dispose();
  }

  Future<void> _retrieveSavedValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_id = prefs.getString('userId') ?? '';
      userName = prefs.getString('userName') ?? '';
      userCity = prefs.getString('userCity') ?? '';
      userDesignation = prefs.getString('userDesignation') ?? '';
      userBrand = prefs.getString('userBrand') ?? '';
      userSM = prefs.getString('userSM') ?? '';
      userNSM = prefs.getString('userNSM') ?? '';
      userRSM = prefs.getString('userRSM') ?? '';
      shopVisitHeadsHighestSerial = prefs.getInt('shopVisitHeadsHighestSerial') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 📱 Get screen sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1000;

    // Dynamic UI scaling
    final gridCrossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
    final iconSize = isTablet ? 45.0 : 36.0;
    final textSize = isTablet ? 16.0 : 13.0;
    final paddingValue = isTablet ? 24.0 : 16.0;
    final verticalSpacing = isTablet ? 20.0 : 10.0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingValue, vertical: 15),
            child: Column(
              children: [
                // 🧩 Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ProfileSection()],
                  ),
                ),

                SizedBox(height: verticalSpacing),

                // 🕒 Timer Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 60),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TimerCard(),
                    ),
                  ),
                ),

                SizedBox(height: verticalSpacing),

                // 🔳 Responsive Grid Menu
                Expanded(
                  child: GridView.count(
                    crossAxisCount: gridCrossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 15,
                    children: [
                      _buildModernCard(
                          context, "SHOP VISIT", Icons.store_mall_directory_rounded, Colors.blueGrey, iconSize, textSize),
                      _buildModernCard(
                          context, "BOOKERS STATUS", Icons.people_alt_rounded, Colors.blueGrey.shade700, iconSize, textSize),
                      _buildModernCard(
                          context, "SHOPS DETAILS", Icons.info_outline_rounded, Colors.blueGrey.shade700, iconSize, textSize),
                      _buildModernCard(
                          context, "BOOKERS ORDER DETAILS", Icons.receipt_long_rounded, Colors.blueGrey, iconSize, textSize),
                      _buildModernCard(
                          context, "LOCATION", Icons.location_on_rounded, Colors.blueGrey, iconSize, textSize),
                    ],
                  ),
                ),

                // 🔖 Version text
                SizedBox(height: verticalSpacing / 2),
                Text(
                  "$version",
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      double iconSize,
      double textSize,
      ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _navigateToPage(context, title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: textSize,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, String title) {
    switch (title) {
      case 'SHOP VISIT':
        final locationVM = Get.find<LocationViewModel>();
        if (locationVM.isClockedIn.value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const NSMShopVisitPage()));
        } else {
          _showClockInDialog(context);
        }
        break;

      case 'BOOKERS STATUS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NSMBookingStatus()));
        break;

      case 'SHOPS DETAILS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NSMShopDetailPage()));
        break;

      case 'BOOKERS ORDER DETAILS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NsmOrderDetailsScreen()));
        break;

      case 'LOCATION':
        Navigator.push(context, MaterialPageRoute(builder: (context) => const NsmLocationNavigation()));
        break;
    }
  }

  void _showClockInDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clock In Required'),
        content: const Text('Please clock in before visiting a shop.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
