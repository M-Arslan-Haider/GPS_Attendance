
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:get/get.dart';
import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
import '../../Databases/util.dart';
import '../../ViewModels/order_master_view_model.dart';
import '../../ViewModels/shop_visit_view_model.dart';
import '../../Databases/dp_helper.dart';

Widget buildActionButtonsRow(OrderBookingStatusViewModel viewModel) {
  final OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());
  final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
  final OrderMasterViewModel orderMasterViewModel = Get.find<OrderMasterViewModel>();

  String _getFormattedDate([DateTime? date]) {
    final DateTime now = date ?? DateTime.now();
    return DateFormat('dd-MM-yyyy').format(now);
  }

  Future<void> generateOrderPDF() async {
    String currentDate = _getFormattedDate();
    final pdf = pw.Document();
    final controller = Get.find<OrderBookingStatusViewModel>();
    final filteredData = controller.filteredRows;

    // Safe date parsing
    DateTime startDate, endDate;
    try {
      startDate = DateTime.parse(controller.startDate.value);
    } catch (_) {
      startDate = DateTime.now();
    }

    try {
      endDate = DateTime.parse(controller.endDate.value);
    } catch (_) {
      endDate = DateTime.now();
    }

    final formattedStartDate = DateFormat('yyyy-MMM-dd').format(startDate);
    final formattedEndDate = DateFormat('yyyy-MMM-dd').format(endDate);

    // Calculate totals
    final totalOrders = filteredData.length;
    final totalAmount = filteredData.fold<double>(
      0.0,
          (sum, order) => sum + (double.tryParse(order.amount.toString()) ?? 0.0),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Valor Trading Order Booking Status',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              'Booker ID: $user_id',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Booker Name: ${shopVisitViewModel.booker_name}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Print Date: $currentDate',
              style: pw.TextStyle(fontSize: 12),
            ),

            pw.SizedBox(height: 5),

            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 4),
              child: pw.Text(
                'Date Range: Start Date: $formattedStartDate | End Date: $formattedEndDate',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontStyle: pw.FontStyle.italic,
                  color: PdfColors.black,
                ),
              ),
            ),

            pw.SizedBox(height: 10),

            pw.Table.fromTextArray(
              context: context,
              headers: ['Order No', 'Shop Name', 'Amount', 'Date'],
              data: filteredData.map((order) {
                return [
                  order.orderNo.toString(),
                  order.shop,
                  order.amount.toString(),
                  order.date,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: PdfColors.white,
              ),
              headerDecoration: pw.BoxDecoration(color: PdfColors.blueGrey900),
              cellStyle: pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.center,
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
              cellPadding: const pw.EdgeInsets.all(6),
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey),
            ),

            pw.SizedBox(height: 10),
            pw.Divider(),

            // Summary section
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total Orders: $totalOrders',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Powered By MetaXperts!',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    try {
      final directory = await getTemporaryDirectory();
      final output = File('${directory.path}/Order_Booking_Status.pdf');
      await output.writeAsBytes(await pdf.save());
      final xfile = XFile(output.path);
      await Share.shareXFiles([xfile], text: 'Order Booking PDF');
    } catch (e) {
      print("Error generating order PDF: $e");
    }
  }

  Future<void> generateProductsPDF() async {
    final pdf = pw.Document();
    String currentDate = _getFormattedDate();
    String ordersDate = 'All Dates';

    final Database? db = await DBHelper().db;
    if (db == null) {
      print("Database is not initialized!");
      return;
    }

    List<Map<String, dynamic>> queryRows = await db.query('orderDetails');

    List<List<String>> productTableData = queryRows.isNotEmpty
        ? queryRows.map((order) {
      String productName = order['product'] ?? 'N/A';
      String quantity = order['quantity']?.toString() ?? '0';
      return [productName, quantity];
    }).toList()
        : [['No Products Found', '0']];

    int totalOrders = queryRows.length;
    int itemsPerPage = 20;
    int pageCount = (productTableData.length / itemsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
      int startIndex = pageIndex * itemsPerPage;
      int endIndex = (startIndex + itemsPerPage).clamp(0, productTableData.length);
      List<List> currentPageData = productTableData.sublist(startIndex, endIndex);

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'Product Details - Page ${pageIndex + 1}',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey300,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Booker ID: $user_id', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Booker Name: ${shopVisitViewModel.booker_name}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Print Date: $currentDate', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Orders/Products Date: $ordersDate', style: const pw.TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Product Details:',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Quantity', 'Date'],
                  data: currentPageData,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellAlignment: pw.Alignment.centerLeft,
                  oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  border: const pw.TableBorder(
                    horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey),
                    bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
                  ),
                  cellPadding: const pw.EdgeInsets.all(6),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(4),
                    color: PdfColors.grey300,
                  ),
                  child: pw.Text('Total Orders: $totalOrders',
                      style: pw.TextStyle(fontSize: 19, fontWeight: pw.FontWeight.bold)),
                ),
              ],
            );
          },
        ),
      );
    }

    try {
      final directory = await getTemporaryDirectory();
      final output = File('${directory.path}/Products_Details PDF.pdf');
      await output.writeAsBytes(await pdf.save());
      final xfile = XFile(output.path);
      await Share.shareXFiles([xfile], text: 'Product Details PDF');
    } catch (e) {
      print("Error saving or sharing PDF: $e");
    }
  }

  void handleButtonAction(String action) async {
    if (action == 'Order PDF') {
      await generateOrderPDF();
    } else if (action == 'Products PDF') {
      await generateProductsPDF();
    }
  }

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      ElevatedButton(
        onPressed: () => handleButtonAction('Order PDF'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
        child: const Text('Order PDF', style: TextStyle(color: Colors.white, fontSize: 15)),
      ),
      ElevatedButton(
        onPressed: () => handleButtonAction('Products PDF'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
        child: const Text('Products PDF', style: TextStyle(color: Colors.white, fontSize: 15)),
      ),
    ],
  );
}

























//
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:printing/printing.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:get/get.dart';
// import 'package:order_booking_app/ViewModels/ScreenViewModels/order_booking_status_view_model.dart';
// import '../../Databases/util.dart';
// import '../../ViewModels/order_master_view_model.dart';
// import '../../ViewModels/shop_visit_view_model.dart';
// import '../../Databases/dp_helper.dart';
//
// List<DataRow> dataRows = [];
// OrderBookingStatusViewModel orderBookingStatusViewModel =
// Get.put(OrderBookingStatusViewModel());
// String _getFormattedDate() {
//   return DateFormat('dd-MMM-yyyy').format(DateTime.now());
// }
//
// Widget buildActionButtonsRow(OrderBookingStatusViewModel viewModel) {
//   OrderDetailsViewModel orderDetailsViewModel =
//   Get.put(OrderDetailsViewModel());
//   final ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());
//   final OrderMasterViewModel orderMasterViewModel =
//   Get.find<OrderMasterViewModel>();
//   String _getFormattedDate([DateTime? date]) {
//     final DateTime now = date ?? DateTime.now();
//     return DateFormat('dd-MM-yyyy').format(now);
//   }
//
//   // Define a footer
//   pw.Widget buildFooter() {
//     return pw.Container(
//       alignment: pw.Alignment.center,
//       margin: const pw.EdgeInsets.only(top: 10),
//       child: pw.Text(
//         'Powered By MetaXperts!',
//         style: pw.TextStyle(
//           fontSize: 12,
//           fontStyle: pw.FontStyle.italic,
//           color: PdfColors.grey,
//         ),
//       ),
//     );
//   }
//
//
//   Future<void> generateOrderPDF() async {
//     if (kDebugMode) {
//       print('Raw data frommmmmmmmmm orderMasterViewModel.allOrderMaster:');
//       for (var order in orderMasterViewModel.allOrderMaster) {
//         print({
//           'order_master_id': order.order_master_id,
//           'shop_name': order.shop_name,
//           'total': order.total,
//         });
//       }
//     }
//
//
//
//     final pdf = pw.Document();
//     String currentDate = _getFormattedDate();
//     String ordersDate = (orderBookingStatusViewModel.startDate.value != null &&
//         orderBookingStatusViewModel.endDate.value != null)
//         ? '${orderBookingStatusViewModel.startDate.value} - ${orderBookingStatusViewModel.endDate.value}'
//         : 'Date Not Selected';
//
//     // Extract data from OrderMasterViewModel
//     List<List<String>> rowsData = [];
//     double totalAmount = 0.0;
//     int totalOrders = orderMasterViewModel.allOrderMaster.length;
//
//     for (var order in orderMasterViewModel.allOrderMaster) {
//       String amountText = (order.total ?? '0').replaceAll(RegExp(r'[^\d.]'), '');
//       double amount = double.tryParse(amountText) ?? 0.0;
//       totalAmount += amount;
//
//       rowsData.add([
//         order.order_master_id ?? '-',
//         order.shop_name ?? '-',
//         'PKR ${amountText}',
//         order.required_delivery_date ?? '-',
//       ]);
//     }
//
//     // Generate PDF page
//     int itemsPerPage = 20; // Or set as desired
//     int pageCount = (rowsData.length / itemsPerPage).ceil();
//
//     for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
//       int startIndex = pageIndex * itemsPerPage;
//       int endIndex = (startIndex + itemsPerPage).clamp(0, rowsData.length);
//       List<List<String>> currentPageData = rowsData.sublist(startIndex, endIndex);
//
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('Valor Trading Order Booking Status',
//                     style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                 pw.SizedBox(height: 10),
//                 pw.Text('Booker ID: $user_id'),
//                 pw.Text('Booker Name: ${shopVisitViewModel.booker_name}'),
//                 pw.Text('Print Date: $currentDate'),
//                 pw.Text('Orders Date: $ordersDate'),
//                 pw.SizedBox(height: 10),
//
//                 pw.Table.fromTextArray(
//                   headers: ['Order No', 'Shop Name', 'Amount', 'Date'],
//                   data: currentPageData,
//                   headerStyle: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     fontSize: 12,
//                     color: PdfColors.white,
//                   ),
//                   headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
//                   cellStyle: const pw.TextStyle(fontSize: 10),
//                   cellAlignment: pw.Alignment.center,
//                   cellPadding: const pw.EdgeInsets.all(6),
//                   oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                   border: null,
//                 ),
//
//                 pw.SizedBox(height: 10),
//                 if (pageIndex == pageCount - 1) ...[
//                   pw.Divider(),
//                   pw.Text('Total Orders: $totalOrders', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                   pw.Text('Total Amount: PKR ${totalAmount.toStringAsFixed(2)}',
//                       style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//                   buildFooter(),
//                 ] else
//                   pw.Align(
//                     alignment: pw.Alignment.centerRight,
//                     child: pw.Text('Page ${pageIndex + 1} of $pageCount'),
//                   ),
//               ],
//             );
//           },
//         ),
//       );
//     }
//
//
//     // **Save the PDF file**
//     try {
//       final directory = await getTemporaryDirectory();
//       final filePath = '${directory.path}/Order_Booking_Status.pdf';
//       final file = File(filePath);
//       await file.writeAsBytes(await pdf.save());
//
//       print("PDF Saved at: $filePath, Size: ${await file.length()} bytes");
//
//       // **Share the PDF file**
//       final xfile = XFile(filePath);
//       await Share.shareXFiles([xfile], text: 'Here is your Order Booking Status PDF.');
//     } catch (e) {
//       print("Error saving or sharing PDF: $e");
//     }
//   }
//
//
//
//
//
//   generateProductsPDF() async {
//     final pdf = pw.Document();
//     String currentDate = _getFormattedDate();
//     String ordersDate = 'All Dates'; // No date range, show as 'All Dates'
//
//     if (kDebugMode) {
//       print("Generating PDF for all order data.");
//     }
//
//     final Database? db = await DBHelper().db;
//     if (db == null) {
//       print("Database is not initialized!");
//       return;
//     }
//
//     // Fetch all rows without date filter
//     List<Map<String, dynamic>> queryRows = await db.query('orderDetails');
//     print("Query Result Rows: ${queryRows.length}"); // Debug log
//
//     List<List<String>> productTableData = queryRows.isNotEmpty
//         ? queryRows.map((order) {
//       String productName = order['product'] ?? 'N/A';
//       String quantity = order['quantity']?.toString() ?? '0';
//       return [productName, quantity];
//     }).toList()
//         : [['No Products Found', '0']];
//
//     int totalOrders = queryRows.length;
//
//     int itemsPerPage = 20;
//     int pageCount = (productTableData.length / itemsPerPage).ceil();
//
//     for (int pageIndex = 0; pageIndex < pageCount; pageIndex++) {
//       int startIndex = pageIndex * itemsPerPage;
//       int endIndex = (startIndex + itemsPerPage).clamp(0, productTableData.length);
//       List<List> currentPageData = productTableData.sublist(startIndex, endIndex);
//
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Center(
//                   child: pw.Text(
//                     '$companyName Products Details - Page ${pageIndex + 1}',
//                     style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
//                   ),
//                 ),
//                 pw.SizedBox(height: 10),
//
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(8),
//                   decoration: pw.BoxDecoration(
//                     borderRadius: pw.BorderRadius.circular(4),
//                     color: PdfColors.grey300,
//                   ),
//                   child: pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('Booker ID: $user_id}',
//                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
//                       pw.Text('Booker Name: ${shopVisitViewModel.booker_name}',
//                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
//                       pw.Text('Print Date: $currentDate',
//                           style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
//                       pw.Text('Orders/Products Date: $ordersDate',
//                           style: const pw.TextStyle(fontSize: 16)),
//                     ],
//                   ),
//                 ),
//
//                 pw.SizedBox(height: 20),
//
//                 pw.Text(
//                   'Product Details:',
//                   style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
//                 ),
//                 pw.SizedBox(height: 10),
//
//                 pw.Table.fromTextArray(
//                   headers: ['Product Name', 'Quantity'],
//                   data: currentPageData.isNotEmpty
//                       ? currentPageData
//                       : [['No Products Found', '0']],
//                   headerStyle: pw.TextStyle(
//                     fontWeight: pw.FontWeight.bold,
//                     fontSize: 12,
//                     color: PdfColors.white,
//                   ),
//                   headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
//                   cellStyle: const pw.TextStyle(fontSize: 10),
//                   cellAlignment: pw.Alignment.centerLeft,
//                   oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                   border: const pw.TableBorder(
//                     horizontalInside: pw.BorderSide(width: 0.5, color: PdfColors.grey),
//                     bottom: pw.BorderSide(width: 0.5, color: PdfColors.black),
//                   ),
//                   cellPadding: const pw.EdgeInsets.all(6),
//                 ),
//
//                 pw.SizedBox(height: 20),
//                 pw.Divider(),
//
//                 pw.Container(
//                   padding: const pw.EdgeInsets.all(8),
//                   decoration: pw.BoxDecoration(
//                     borderRadius: pw.BorderRadius.circular(4),
//                     color: PdfColors.grey300,
//                   ),
//                   child: pw.Text('Total Orders: $totalOrders',
//                       style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//                 ),
//               ],
//             );
//           },
//         ),
//       );
//     }
//
//     try {
//       final directory = await getTemporaryDirectory();
//       final output = File('${directory.path}/Products PDF.pdf');
//       await output.writeAsBytes(await pdf.save());
//       print("PDF Saved at: ${output.path}, Size: ${await output.length()} bytes"); // Debug file size
//       final xfile = XFile(output.path);
//       await Share.shareXFiles([xfile], text: 'PDF Document');
//     } catch (e) {
//       print("Error saving or sharing PDF: $e");
//     }
//   }
//
//
//   // Handle PDF generation actions
//   void handleButtonAction(String action) async {
//     if (action == 'Order PDF') {
//       await generateOrderPDF();
//     } else if (action == 'Products PDF') {
//       await generateProductsPDF();
//     }
//   }
//
//   return Row(
//     mainAxisAlignment: MainAxisAlignment.spaceAround,
//     children: [
//       ElevatedButton(
//         onPressed: generateOrderPDF,
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//         child: const Text('Order PDF',style: TextStyle(color: Colors.white,fontSize: 15),),
//       ),
//       ElevatedButton(
//         onPressed: generateProductsPDF,
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//         child: const Text('Products PDF',style: TextStyle(color: Colors.white,fontSize: 15),),
//       ),
//     ],
//   );
// }