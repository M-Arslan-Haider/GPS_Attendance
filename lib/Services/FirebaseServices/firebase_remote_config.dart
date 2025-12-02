import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:order_booking_app/Databases/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static late FirebaseRemoteConfig remoteConfig;
  static String? _erpCompanyName; // Cached value

  static Future<void> initialize() async {

    remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      // Set to 1 minute for development; change to a larger interval for production
      minimumFetchInterval: const Duration(seconds: 1),
    ));
    await fetchLatestConfig(); // Fetch and activate immediately
    // Load from SharedPreferences once during initialization
    final prefs = await SharedPreferences.getInstance();
    erpWorkSpace = prefs.getString('workspace_name');
  }

  static Future<void> fetchLatestConfig() async {
    try {
      bool updated = await remoteConfig.fetchAndActivate();
      if (updated) {
        if (kDebugMode) {
          debugPrint('Remote config updated');
        }
      } else {
        if (kDebugMode) {
          debugPrint('No changes in remote config');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to fetch remote config: $e');
      }
    }
  }

  static String get getApiUrlServer => remoteConfig.getString('ServerGetUrl');
  static String get getApiUrlCompaniesCodes => remoteConfig.getString('CompaniesCodesGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/loginget/get/');
  // static String get getApiUrlERPCompanyName =>
  //     remoteConfig.getString('ERPCompanyNameGetUrl');
  static String get getApiUrlERPCompanyName =>
      erpWorkSpace ?? '';

  // 'https://cloud.metaxperts.net:8443/erp/test1/
  static String get getApiUrlServerIP =>
      remoteConfig.getString('ServerIPGetUrl');
  // 'https://cloud.metaxperts.net:8443/
  // Config.getApiUrlServerIP}{Config.getApiUrlERPCompanyName}{Config.getApiUrlLogin
// Static configuration parameters for GET API URLs
  static String get getApiUrlLogin => remoteConfig.getString('LoginGetUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/loginget/get/
  static String get getApiUrlShops => remoteConfig.getString('ShopsGetUrl');
  //        'https://cloud.metaxperts.net:8443/erp/test1/shopget/get/');
  static String get getApiUrlShopsUserId =>
      remoteConfig.getString('ShopsUserIdGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/shopgetid/get/$user_id');

  static String get getApiUrlShops1 => remoteConfig.getString('ShopsGetUrl1');
  static String get getApiUrlShops2 => remoteConfig.getString('ShopsGetUrl2');
  static String get getApiUrlShops3 => remoteConfig.getString('ShopsGetUrl3');
  static String get getApiUrlShops4 => remoteConfig.getString('ShopsGetUrl4');

  static String get getApiUrlShopVisitDetails =>
      remoteConfig.getString('ShopVisitDetailsGetUrl');
  static String get getApiUrlLocation =>
      remoteConfig.getString('LocationGetUrl');
  static String get getApiUrlAttendanceIn =>
      remoteConfig.getString('AttendanceInGetUrl');
  static String get getApiUrlAttendanceOut =>
      remoteConfig.getString('AttendanceOutGetUrl');

  static String get getApiUrlProducts =>
      remoteConfig.getString('ProductsGetUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/products/get/
  static String get getApiUrls => remoteConfig.getString('BrandsGetUrl');
//
  static String get getApiUrlCities => remoteConfig.getString('CitiesGetUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/cities/get/

  static String get getApiUrlOrderMaster =>
      remoteConfig.getString('OrderMasterGetUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/ordermasterget/get/$user_id

  static String get getApiUrlOrderDetails =>
      remoteConfig.getString('OrderDetailsGetUrl');
  //'https://cloud.metaxperts.net:8443/erp/test1/orderdetailsget/get/$user_id'

  static String get getApiUrlRecoveryForm =>
      remoteConfig.getString('RecoveryFormGetUrl');

  static String get getApiUrlCurrentBalance =>
      remoteConfig.getString('CurrentBalanceGetUrl');

  static String get getApiUrlReturnForm =>
      remoteConfig.getString('ReturnFormUrl');

  static String get getApiUrlReturnFormDetails =>
      remoteConfig.getString('ReturnFormDetailsGetUrl');

  static String get getApiUrlShopVisit =>
      remoteConfig.getString('ShopVisitGetUrl');

  static String get getApiUrlShopVisitHeads =>
      remoteConfig.getString('ShopVisitHeadsGetUrl');

  static String get getApiUrlStockCheckItems =>
      remoteConfig.getString('StockCheckItemsGetUrl');

  static String get getApiUrlOrderBookingStatus =>
      remoteConfig.getString('OrderBookingStatusGetUrl');



  static String get getApiUrlShopVisitTotal =>
      remoteConfig.getString('ShopVisitTotalGetUrl');

  static String get getApiUrlOrderMasterDispatchedTotal =>
      remoteConfig.getString('OrderMasterDispatchedTotalGetUrl');




///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  static String get getApiUrlHeadsAttendanceData =>
      remoteConfig.getString('HeadsAttendanceDataGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/attendancedata/get/$user_id/'),

  static String get getApiUrlNsmShop =>
      remoteConfig.getString('NsmShopsGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmshops/get/$user_id';
  static String get getApiUrlRsmShop =>
      remoteConfig.getString('RsmShopsGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/rsmshops/get/$user_id';
  static String get getApiUrlSmShop =>
      remoteConfig.getString('SmShopsGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/smshops/get/$user_id';

  static String get getApiUrlNsmBookersStatus =>
      remoteConfig.getString('NsmBookersStatusGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmbookerstatus/get/$user_id';
  static String get getApiUrlNsmRsmStatus =>
      remoteConfig.getString('NsmRsmStatusGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmrsmstatus/get/$user_id';
  static String get getApiUrlNsmSmStatus =>
      remoteConfig.getString('NsmSmStatusGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmsmstatus/get/$user_id';

  static String get getApiUrlSmRsmStatus =>
      remoteConfig.getString('SmRsmStatusGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/smrsmstatus/get/$user_id';
  static String get getApiUrlSmBookersStatus =>
      remoteConfig.getString('SmBookersStatusGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/smbookerstatus/get/$user_id';

  static String get getApiUrlRsmBookersStatus =>
      remoteConfig.getString('RsmBookersStatusGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/rsmbookerstatus/get/$user_id';


  static String get getApiUrlNsmSmOrder =>
      remoteConfig.getString('NsmSmOrderGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmorders/get/11';
  static String get getApiUrlNsmRsmOrder =>
      remoteConfig.getString('NsmRsmOrderGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmrsmorders/get/$user_id';
  static String get getApiUrlNsmUserOrder =>
      remoteConfig.getString('NsmUserOrderGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmuserorders/get/$user_id';

  static String get getApiUrlNsmSmOrderDetails =>
      remoteConfig.getString('NsmSmOrderDetailsGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/nsmsmorderdetails/get/$user_id/${widget.booker.booker_id}'),

  static String get getApiUrlNsmRsmOrderDetails =>
      remoteConfig.getString('NsmRsmOrderDetailsGetUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/nsmrsmorderdetails/get/$user_id/${widget.booker.booker_id}
  static String get getApiUrlNsmUserOrderDetails =>
      remoteConfig.getString('NsmUserOrderDetailsGetUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/nsmuserorderdetails/get/$user_id/${widget.booker.booker_id}

  static String get getApiUrlSmRsmOrder =>
      remoteConfig.getString('SmRsmOrderGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/smrsmorders/get/$user_id';
  static String get getApiUrlSmUserOrder =>
      remoteConfig.getString('SmUserOrderGetUrl');
  //final url = 'https://cloud.metaxperts.net:8443/erp/test1/smuserorders/get/$user_id';

  static String get getApiUrlSmRsmOrderDetails =>
      remoteConfig.getString('SmRsmOrderDetailsGetUrl');
  //   Uri.parse('https://cloud.metaxperts.net:8443/erp/test1/smrsmorderdetails/get/$user_id/${widget.booker.booker_id}'),
  static String get getApiUrlSmUserOrderDetails =>
      remoteConfig.getString('SmUserOrderDetailsGetUrl');
  // final url = 'https://cloud.metaxperts.net:8443/erp/test1/smuserorderdetails/get/$user_id';

  static String get getApiUrlRsmUserOrderDetails =>
      remoteConfig.getString('RsmUserOrderDetailsGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/rsmuserorderdetails/get/$user_id/${widget.booker.booker_id}'),

  static String get getApiUrlRsmUserOrder =>
      remoteConfig.getString('RsmUserOrderGetUrl');
  //final url = 'https://cloud.metaxperts.net:8443/erp/test1/rmuserorders/get/$user_id';
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///
  ///NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM//////NSM///SM///RSM///



  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  static String get getApiUrlProductsWithTime =>
      remoteConfig.getString('ProductsWthTimeGetUrl');
  // 'https://cloud.metaxperts.net:8443/erp/test1/productgettime/get/$formattedDateTime');
  static String get getApiUrlOrderMasterWithTime =>
      remoteConfig.getString('OrderMasterWthTimeGetUrl');
  //        'https://cloud.metaxperts.net:8443/erp/test1/ordermastergettime/get/$user_id/$formattedDateTime');
  static String get getApiUrlCitiesWithTime =>
      remoteConfig.getString('CitiesWthTimeGetUrl');
  //     "https://cloud.metaxperts.net:8443/erp/test1/citiestime/get/$formattedDateTime";

  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///
  ///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///WITH TIME///

///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
  static String get getApiUrlShopVisitSerial =>
      remoteConfig.getString('ShopVisitSerialGetUrl');
  //'https://cloud.metaxperts.net:8443/erp/test1/shopvisitserial/get/$user_id'
  static String get getApiUrlShopVisitDetailsSerial =>
      remoteConfig.getString('ShopVisitDetailsSerialGetUrl');
  //      apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/stockitemserial/get/$user_id',
  static String get getApiUrlOrderMasterSerial =>
      remoteConfig.getString('OrderMasterSerialGetUrl');
//  apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/ordermasterserial/get/$user_id',
  static String get getApiUrlOrderDetailsSerial =>
      remoteConfig.getString('OrderDetailsSerialGetUrl');
  //apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/orderdetailserial/get/$user_id',
  static String get getApiUrlReturnFormSerial =>
      remoteConfig.getString('ReturnFormSerialGetUrl');
  //  apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/returnmasterserial/get/$user_id',
  static String get getApiUrlReturnFormDetailsSerial =>
      remoteConfig.getString('ReturnFormDetailsSerialGetUrl');
  //     apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/returndetailserial/get/$user_id',
  static String get getApiUrlAttendanceInSerial =>
      remoteConfig.getString('AttendanceInSerialGetUrl');
  //      apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/attendanceinserial/get/$user_id',
  static String get getApiUrlAttendanceOutSerial =>
      remoteConfig.getString('AttendanceOutSerialGetUrl');
  //apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/attendanceoutserial/get/$user_id',
  static String get getApiUrlLocationSerial =>
      remoteConfig.getString('LocationSerialGetUrl');
  //      apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/locationserial/get/$user_id',
  static String get getApiUrlShopSerial =>
      remoteConfig.getString('ShopSerialGetUrl');
//       apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/shopserial/get/$user_id',
  static String get getApiUrlRecoveryFormSerial =>
      remoteConfig.getString('RecoveryFormSerialGetUrl');
  //      apiUrl: 'https://cloud.metaxperts.net:8443/erp/test1/recoveryserial/get/$user_id',
  ///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
  ///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
  ///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
  ///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get
  ///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get///Serial Get



/// Static configuration parameters for POST API URLs with postApiUrl prefix  ///
/// Static configuration parameters for POST API URLs with postApiUrl prefix  ///
/// Static configuration parameters for POST API URLs with postApiUrl prefix  ///
/// Static configuration parameters for POST API URLs with postApiUrl prefix  ///
/// Static configuration parameters for POST API URLs with postApiUrl prefix  ///
/// Static configuration parameters for POST API URLs with postApiUrl prefix  ///
  static String get postApiUrlShopVisitDetails =>
      remoteConfig.getString('ShopVisitDetailsPostUrl');
  //https://cloud.metaxperts.net:8443/erp/test1/headshopvisit/post/

  static String get postApiUrlShops => remoteConfig.getString('ShopsPostUrl');

  static String get postApiUrlProducts =>
      remoteConfig.getString('ProductsPostUrl');

  static String get postApiUrlBrands => remoteConfig.getString('BrandsPostUrl');

  static String get postApiUrlOrderMaster =>
      remoteConfig.getString('OrderMasterPostUrl');

  static String get postApiUrlOrderDetails =>
      remoteConfig.getString('OrderDetailsPostUrl');

  static String get postApiUrlRecoveryForm =>
      remoteConfig.getString('RecoveryFormPostUrl');

  static String get postApiUrlReturnForm =>
      remoteConfig.getString('ReturnFormPostUrl');

  static String get postApiUrlReturnFormDetails =>
      remoteConfig.getString('ReturnFormDetailsPostUrl');

  static String get postApiUrlShopVisit => remoteConfig.getString(
      'ShopVisitPostUrl'); //https://cloud.metaxperts.net:8443/erp/test1/headshopvisit/post/
  static String get postApiUrlShopVisitHeads =>
      remoteConfig.getString('ShopVisitHeadsPostUrl');
  // "https://cloud.metaxperts.net:8443/erp/test1/headshopvisit/post/"

  static String get postApiUrlAttendanceIn =>
      remoteConfig.getString('AttendanceInPostUrl');

  static String get postApiUrlAttendanceOut =>
      remoteConfig.getString('AttendanceOutPostUrl');

  static String get postApiUrlLocation =>
      remoteConfig.getString('LocationPostUrl');

  // static String get postApiUrlTravelData => remoteConfig.getString('traveldataGetUrl');
  static String get postApiUrlTravelData => remoteConfig.getString('traveldataGetUrl');
  static String get postApiUrlcenterpoint => remoteConfig.getString('centerPointUrl');


}
