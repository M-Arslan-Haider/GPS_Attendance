// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
// import 'package:order_booking_app/screens/OrderBookingStatusScreenComponents/order_booking_status_history_card.dart';
// import 'OrderBookingStatusScreenComponents/build_action_button_row.dart';
// import 'OrderBookingStatusScreenComponents/build_date_range.dart';
// import 'OrderBookingStatusScreenComponents/build_shop_and_order_row.dart';
// import 'OrderBookingStatusScreenComponents/build_status_and_button_row.dart';
//
// class OrderBookingStatusScreen extends StatelessWidget {
//   OrderBookingStatusScreen({super.key});
//   final viewModel = Get.put(OrderBookingStatusViewModel());
//   // final viewModel = Get.put(OrderBookingStatusViewModel());
//
//   @override
//   Widget build(BuildContext context) {
//     // Fetch the orders as soon as the screen is displayed
//     viewModel.fetchOrders();
//     Size size = MediaQuery.of(context).size;
//     return SafeArea(
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Order Booking Status',
//             style: TextStyle(color: Colors.white, fontSize: 24),
//           ),
//           centerTitle: true,
//           backgroundColor: Colors.blueGrey,
//
//
//         ),
//         body: Container(
//           color: Colors.white,
//           width: size.width,
//           height: size.height,
//           padding: const EdgeInsets.all(20),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 Obx(() => buildShopAndOrderRow(viewModel)), // Observe changes
//                 const SizedBox(height: 20),
//                 Obx(()=> buildDateRangeRow(context, viewModel)),
//                 const SizedBox(height: 20),
//                 Obx(() => buildStatusAndButtonRow(viewModel)),
//                 const SizedBox(height: 20),
//                 buildActionButtonsRow(viewModel),
//                 const SizedBox(height: 20),
//                 OrderBookingStatusHistoryCard(
//                   filterData: (filter) => viewModel.filterData(filter),
//                   rowsNotifier: ValueNotifier(viewModel.filteredRowsAsMapList),
//                   viewModel: viewModel,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
import 'package:order_booking_app/screens/OrderBookingStatusScreenComponents/order_booking_status_history_card.dart';
import 'OrderBookingStatusScreenComponents/build_action_button_row.dart';
import 'OrderBookingStatusScreenComponents/build_date_range.dart';
import 'OrderBookingStatusScreenComponents/build_shop_and_order_row.dart';
import 'OrderBookingStatusScreenComponents/build_status_and_button_row.dart';

class OrderBookingStatusScreen extends StatelessWidget {
  OrderBookingStatusScreen({super.key});

  final viewModel = Get.put(OrderBookingStatusViewModel());

  @override
  Widget build(BuildContext context) {
    // Fetch the orders as soon as the screen is displayed
    viewModel.fetchOrders();

    Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Order Booking Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey,

          // 🔹 Back arrow color changed to white
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: Container(
          color: Colors.white,
          width: size.width,
          height: size.height,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(() => buildShopAndOrderRow(viewModel)),
                const SizedBox(height: 20),
                Obx(() => buildDateRangeRow(context, viewModel)),
                const SizedBox(height: 20),
                Obx(() => buildStatusAndButtonRow(viewModel)),
                const SizedBox(height: 20),
                buildActionButtonsRow(viewModel),
                const SizedBox(height: 20),
                OrderBookingStatusHistoryCard(
                  filterData: (filter) => viewModel.filterData(filter),
                  rowsNotifier: ValueNotifier(
                    viewModel.filteredRowsAsMapList,
                  ),
                  viewModel: viewModel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
