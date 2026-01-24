import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:order_booking_app/Screens/home_screen.dart';
import 'package:order_booking_app/ViewModels/order_details_view_model.dart';
import 'package:order_booking_app/ViewModels/order_master_view_model.dart';
import 'package:order_booking_app/ViewModels/shop_visit_view_model.dart';
import 'package:path_provider/path_provider.dart';
import '../Databases/util.dart';
import 'Components/custom_button.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'order_booking_status_screen.dart'; //

bool isPressed = false;
bool isButtonDisabled = false; // Add this flag

class ReconfirmOrderScreen extends StatefulWidget {
  final List<Map<String, dynamic>> rows;

  const ReconfirmOrderScreen({required this.rows, super.key});

  @override
  _ReconfirmOrderScreenState createState() => _ReconfirmOrderScreenState();
}

class _ReconfirmOrderScreenState extends State<ReconfirmOrderScreen> {
  int _currentPage = 0;
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  OrderDetailsViewModel orderDetailsViewModel =
      Get.put(OrderDetailsViewModel());
  ShopVisitViewModel shopVisitViewModel = Get.put(ShopVisitViewModel());

  void _nextPage() {
    setState(() {
      if ((_currentPage + 1) * 10 < widget.rows.length) {
        _currentPage++;
      }
    });
  }

  void _prevPage() {
    setState(() {
      if (_currentPage > 0) {
        _currentPage--;
      }
    });
  }

  List<Map<String, dynamic>> _getCurrentPageRows() {
    int startIndex = _currentPage * 10;
    int endIndex = startIndex + 10;
    if (endIndex > widget.rows.length) {
      endIndex = widget.rows.length;
    }
    return widget.rows.sublist(startIndex, endIndex);
  }

  Future<void> _generateAndSharePDF() async {
    final pdf = pw.Document();

    const baseColor = PdfColors.blueAccent;
    const headerColor = PdfColors.black;
    const alternateRowColor = PdfColors.grey200;
    const tableBorderColor = PdfColors.blueGrey;

    // Load the logo image
    final ByteData logoData = await rootBundle.load('assets/images/logo.png');
    final Uint8List logoBytes = logoData.buffer.asUint8List();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Logo and Title Section in Horizontal Layout
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.Image(
                pw.MemoryImage(logoBytes),
                width: 50,
                height: 50,
              ),
              pw.SizedBox(width: 10),
              pw.Text(
                companyName,
                style: pw.TextStyle(
                  fontSize: 27,
                  fontWeight: pw.FontWeight.bold,
                  color: headerColor,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                'Order Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: headerColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Header Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // First Row: Owner Name (Left) | Order ID (Right)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Owner Name: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: '${shopVisitViewModel.owner_name}',
                          ),
                        ],
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Order ID:    ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: '$order_master_id',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),

                // Second Row: Shop Name (Left) | Phone Number (Right)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Shop Name: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: '${shopVisitViewModel.selectedShop}',
                          ),
                        ],
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Phone Number:  ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: '${shopVisitViewModel.phone_number}',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 5),

                // Third Row: Booker Name (Left) | Date (Right)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Booker Name: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: '${shopVisitViewModel.booker_name}',
                          ),
                        ],
                      ),
                    ),
                    pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text: 'Print Date: ',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.TextSpan(
                            text: DateFormat('dd-MMM-yyyy : HH-mm')
                                .format(DateTime.now()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),
          pw.Text('Order Summary',
              style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: baseColor)),
          pw.SizedBox(height: 10),

          // Table Section
          pw.Table.fromTextArray(
            headers: ['#', 'Product', 'Enter Qty', 'Amount'],
            data: widget.rows.map((row) {
              return [
                widget.rows.indexOf(row) + 1,
                row['Product'] ?? '-',
                row['Enter Qty']?.toString() ?? '-',
                row['Amount']?.toString() ?? '-',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(
              color: baseColor,
            ),
            cellDecoration: (index, row, column) => pw.BoxDecoration(
              color: index % 2 == 0 ? alternateRowColor : PdfColors.white,
            ),
            cellAlignments: {
              0: pw.Alignment.centerRight,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
            border: const pw.TableBorder(
              horizontalInside:
                  pw.BorderSide(color: tableBorderColor, width: 0.5),
              top: pw.BorderSide(color: tableBorderColor, width: 1),
              bottom: pw.BorderSide(color: tableBorderColor, width: 1),
            ),
          ),
          pw.SizedBox(height: 10),
          // Footer Section
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Credit Limit: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.TextSpan(
                          text: orderMasterViewModel.credit_limit.value,
                        ),
                      ],
                    ),
                  ),
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: 'Required Date: ',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.TextSpan(
                          text:
                              orderMasterViewModel.required_delivery_date.value,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.RichText(
                text: pw.TextSpan(
                  children: [
                    pw.TextSpan(
                      text: 'Total: ',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 17),
                    ),
                    pw.TextSpan(
                      text: orderDetailsViewModel.total.value,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],

        // Correctly placed footer
        footer: (context) {
          return pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.only(top: 10),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Left-aligned logo and text
                pw.Row(
                  children: [
                    pw.Text(
                      'Powered By ',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey,
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Container(
                      width: 20,
                      height: 20,
                      decoration: pw.BoxDecoration(
                        shape: pw.BoxShape.circle,
                        image: pw.DecorationImage(
                          image: pw.MemoryImage(logoBytes),
                          fit: pw.BoxFit.cover,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'MetaXperts',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),

                // Right-aligned page number
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(
                      fontSize: 12, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
      ),
    );

    try {
      // Save the PDF file
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/order_invoice.pdf');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Share.shareXFiles([XFile(file.path)], text: 'Order Invoice');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate and share PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Order Invoice',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _generateAndSharePDF();
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (isPressed == true) {
              // Handle case when isPressed is true
            } else {
              Get.to(() => OrderBookingStatusScreen());
              //Get.offNamed("/OrderBookingScreen");
            }
          },
        ),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(label: 'Order ID', value: order_master_id),
            _buildField(
              label: 'Customer Name',
              value: shopVisitViewModel.selectedShop.value,
            ),
            _buildField(
              label: 'Phone Number',
              value: shopVisitViewModel.phone_number.value,
            ),
            const Divider(color: Colors.grey),

            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),

            // **This ensures the order list dynamically adjusts**
            Expanded(
              child: ListView(
                children: [
                  Column(
                    children: _getCurrentPageRows().asMap().entries.map((entry) {
                      int index = entry.key;
                      var row = entry.value;
                      return OrderSummaryRow(
                        serialNumber: (_currentPage * 10) + index + 1,
                        rowData: row,
                      );
                    }).toList(),
                  ),
                  _buildPaginationControls(), // Pagination controls
                  const Divider(color: Colors.grey),
                  const OrderFooter(), // Total Credit Limit, Required Date, etc.
                  const SizedBox(height: 5),
                ],
              ),
            ),

            // **Bottom Button Row** (Moves up dynamically)
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                textSize: 14,
                spacing: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                height: 40,
                width: 120,
                buttonText: "Close",
                onTap: () async {
                  setState(() {
                    isButtonDisabled = false; // Re-enable the button if needed
                  });
                  await shopVisitViewModel.clearFilters();
                  Get.to(() => const HomeScreen());

                  // Get.offNamed("/home");
                },
                gradientColors: [Colors.blueGrey.shade700, Colors.blueGrey],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildField({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Expanded(
              child: Text(value ?? '', style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (_currentPage > 0)
          ElevatedButton(
            onPressed: _prevPage,
            child: const Text('View Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
        if ((_currentPage + 1) * 5 < widget.rows.length)
          ElevatedButton(
            onPressed: _nextPage,
            child: const Text('View Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}

class OrderSummaryRow extends StatelessWidget {
  final int serialNumber;
  final Map<String, dynamic> rowData;

  const OrderSummaryRow({
    Key? key,
    required this.serialNumber,
    required this.rowData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              serialNumber.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 4,
            child:
                Text(rowData['Product'], style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(rowData['Enter Qty'].toString(),
                style: const TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(rowData['Amount'].toString(),
                style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class OrderFooter extends StatefulWidget {
  const OrderFooter({super.key});

  @override
  State<OrderFooter> createState() => _OrderFooterState();
}

class _OrderFooterState extends State<OrderFooter> {
  OrderMasterViewModel orderMasterViewModel = Get.put(OrderMasterViewModel());
  OrderDetailsViewModel orderDetailsViewModel = Get.put(OrderDetailsViewModel());

  String buttonText = "CONFIRM ORDER"; // To change the button text

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildField(
            label: 'Total',
            value: orderDetailsViewModel.total.value,
          ),
          _buildField(
            label: 'Credit Limit',
            value: orderMasterViewModel.credit_limit.value,
          ),
          _buildField(
            label: 'Required Date',
            value: orderMasterViewModel.required_delivery_date.value,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              buttonText: buttonText, // Use the variable for button text
              onTap: isButtonDisabled
                  ? null // Disable the button if isButtonDisabled is true
                  : () async {
                setState(() {
                  isButtonDisabled = true; // Disable the button
                  buttonText = "SUBMITTED"; // Change button text
                });
                isPressed = true;
                await orderMasterViewModel.confirmSubmitForm();

              },
              gradientColors: [Colors.blueGrey, Colors.blueGrey],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({required String label, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}