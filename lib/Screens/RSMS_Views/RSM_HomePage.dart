
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/Screens/leave_form_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart'
    show Permission, PermissionActions, PermissionStatus, PermissionStatusGetters, openAppSettings, ServiceStatus;

import '../../Databases/util.dart';
import '../../Utils/ForceUpdateService.dart';
import '../../ViewModels/add_shop_view_model.dart';
import '../../ViewModels/attendance_out_view_model.dart';
import '../../ViewModels/attendance_view_model.dart';
import '../../ViewModels/location_view_model.dart';
import '../../ViewModels/update_function_view_model.dart';
import '../HomeScreenComponents/profile_section.dart';
import '../HomeScreenComponents/timer_card.dart';
import 'LIVE_location_page.dart';
import 'BookerStatus.dart';
import 'RSMOrderDetails/rsm_order_details_screen.dart';
import 'RSM_ShopDetails.dart';
import 'RSM_ShopVisit.dart';
import 'RSM_bookerbookingdetails.dart';

class RSMHomepage extends StatefulWidget {
  const RSMHomepage({Key? key}) : super(key: key);

  @override
  _RSMHomepageState createState() => _RSMHomepageState();
}

class _RSMHomepageState extends State<RSMHomepage> {
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
    Get.put(AttendanceViewModel());
    Get.put(AttendanceOutViewModel());

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
  //   Get.put(AttendanceViewModel());
  //   Get.put(AttendanceOutViewModel());
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

  _retrieveSavedValues() async {
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
    // 📱 Responsive values using MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isTablet = screenWidth > 600;

    final double padding = isTablet ? 24 : 16;
    final double fontSize = isTablet ? 18 : 13;
    final double iconSize = isTablet ? 50 : 36;
    final int gridCount = isTablet ? 3 : 2;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade50,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
            child: Column(
              children: [
                // 👤 Profile Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
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
                  child: const ProfileSection(),
                ),

                SizedBox(height: padding / 2),

                // ⏱ Timer Card
                Container(
                  width: double.infinity,
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
                    padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TimerCard(),
                    ),
                  ),
                ),

                // SizedBox(height: padding / 2),
                SizedBox(height: padding * 1),

                // 🧩 Grid Menu
                Expanded(
                  child: GridView.count(
                    crossAxisCount: gridCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 15,
                    childAspectRatio: isTablet ? 1.2 : 1,
                    children: [
                      _buildModernCard(
                        context,
                        "SHOP VISIT",
                        Icons.store_mall_directory_rounded,
                        Colors.blueGrey,
                        iconSize,
                        fontSize,
                      ),
                      _buildModernCard(
                        context,
                        "BOOKERS STATUS",
                        Icons.people_alt_rounded,
                        Colors.blueGrey,
                        iconSize,
                        fontSize,
                      ),
                      _buildModernCard(
                        context,
                        "SHOPS DETAILS",
                        Icons.info_outline_rounded,
                        Colors.blueGrey,
                        iconSize,
                        fontSize,
                      ),
                      _buildModernCard(
                        context,
                        "BOOKERS ORDER DETAILS",
                        Icons.receipt_long_rounded,
                        Colors.blueGrey,
                        iconSize,
                        fontSize,
                      ),
                      _buildModernCard(
                        context,
                        "LEAVE",
                        // Icons.sick_outlined,
                        Icons.event_busy,
                        Colors.blueGrey,
                        iconSize,
                        fontSize,
                      ),

                      // _buildModernCard(
                      //   context,
                      //   "LIVE LOCATION",
                      //   Icons.location_on_rounded,
                      //   Colors.orange,
                      //   iconSize,
                      //   fontSize,
                      // ),
                    ],
                  ),
                ),

                SizedBox(height: padding / 3),
                Text(
                  "$version",
                  style: TextStyle(
                    fontSize: fontSize - 1,
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

  /// 🧱 Custom Modern Card Widget
  Widget _buildModernCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      double iconSize,
      double fontSize,
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
              padding: EdgeInsets.all(iconSize / 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🌐 Navigation Logic
  void _navigateToPage(BuildContext context, String title) {
    switch (title) {
      case 'SHOP VISIT':
        final locationVM = Get.find<LocationViewModel>();
        if (locationVM.isClockedIn.value) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ShopVisitPage()));
        } else {
          showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('Clock In Required'),
              content: Text('Please clock in before visiting a shop.'),
            ),
          );
        }
        break;
      case 'BOOKERS STATUS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => RSMBookerStatus()));
        break;
      case 'SHOPS DETAILS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => ShopDetailPage()));
        break;
      case 'BOOKERS ORDER DETAILS':
        Navigator.push(context, MaterialPageRoute(builder: (context) => RsmOrderDetailsScreen()));
        break;
      case 'LIVE LOCATION':
        Navigator.push(context, MaterialPageRoute(builder: (context) => LiveLocationPage()));
        break;
      case 'LEAVE':
        Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveFormScreen()));
        break;
    }
  }
}
