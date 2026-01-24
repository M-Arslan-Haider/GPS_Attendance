// add_shop_report_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Databases/util.dart';
import '../../Models/add_shop_model.dart';
import '../../Services/FirebaseServices/firebase_remote_config.dart';


class AddShopReportScreen extends StatefulWidget {
  const AddShopReportScreen({Key? key}) : super(key: key);

  @override
  _AddShopReportScreenState createState() => _AddShopReportScreenState();
}

class _AddShopReportScreenState extends State<AddShopReportScreen> {
  List<AddShopModel> shops = [];
  bool isLoading = true;
  bool isLoadingDetails = false;
  String errorMessage = '';
  String searchQuery = '';
  // int totalShops = 0;
  // int postedShops = 0;
  // int pendingShops = 0;
  AddShopModel? selectedShop;

  @override
  void initState() {
    super.initState();
    fetchShopRecords();
  }

  Future<void> fetchShopRecords() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // Your API URL
      final baseUrl =  Config.getApiUrlAddShopReport;
      final  url = '$baseUrl/$user_id';
      debugPrint('🔗 Fetching from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('📊 Shop API Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        debugPrint('📊 Response Type: ${responseData.runtimeType}');

        List<AddShopModel> processedShops = [];

        if (responseData is List) {
          for (var item in responseData) {
            if (item is Map) {
              final Map<String, dynamic> convertedItem = {};
              item.forEach((key, value) {
                convertedItem[key.toString()] = value;
              });
              processedShops.add(_processShopItem(convertedItem));
            }
          }
        } else if (responseData is Map) {
          final Map<String, dynamic> convertedResponse = {};
          responseData.forEach((key, value) {
            convertedResponse[key.toString()] = value;
          });

          List<String> possibleListKeys = [
            'data',
            'shops',
            'shop_list',
            'shopList',
            'results',
            'items',
            'records',
            'list'
          ];

          bool foundList = false;
          for (var key in possibleListKeys) {
            if (convertedResponse.containsKey(key) && convertedResponse[key] is List) {
              debugPrint('✅ Found shop data in key: "$key"');
              final dataList = convertedResponse[key] as List;
              for (var item in dataList) {
                if (item is Map) {
                  final Map<String, dynamic> convertedItem = {};
                  item.forEach((k, v) {
                    convertedItem[k.toString()] = v;
                  });
                  processedShops.add(_processShopItem(convertedItem));
                }
              }
              foundList = true;
              break;
            }
          }

          if (!foundList) {
            convertedResponse.forEach((key, value) {
              if (value is List && !foundList) {
                debugPrint('✅ Found list in key: "$key"');
                for (var item in value) {
                  if (item is Map) {
                    final Map<String, dynamic> convertedItem = {};
                    item.forEach((k, v) {
                      convertedItem[k.toString()] = v;
                    });
                    processedShops.add(_processShopItem(convertedItem));
                  }
                }
                foundList = true;
              }
            });
          }
        }

        // Calculate statistics
        int posted = 0;
        int pending = 0;

        for (var shop in processedShops) {
          if (shop.posted == 1) {
            posted++;
          } else {
            pending++;
          }
        }

        setState(() {
          shops = processedShops;
          isLoading = false;
        });


        debugPrint('✅ Successfully loaded ${shops.length} shop records');
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Shop API Error: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load shop records: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  AddShopModel _processShopItem(Map<String, dynamic> item) {
    debugPrint('📋 Processing shop item with keys: ${item.keys}');

    return AddShopModel(
      shop_id: item['shop_id'] ?? item['Shop_Id'] ?? item['shopId'] ?? item['id'] ?? 'N/A',
      shop_name: item['shop_name'] ?? item['Shop_Name'] ?? item['shopName'] ?? item['name'] ?? 'N/A',
      city: item['city'] ?? item['City'] ?? 'N/A',
      shop_address: item['shop_address'] ?? item['Shop_Address'] ?? item['shopAddress'] ?? item['address'] ?? 'N/A',
      shop_live_address: item['shop_live_address'] ?? item['Shop_Live_Address'] ?? item['liveAddress'] ?? item['live_address'] ?? item['address'] ?? 'N/A',
      owner_name: item['owner_name'] ?? item['Owner_Name'] ?? item['ownerName'] ?? item['owner'] ?? 'N/A',
      owner_cnic: item['owner_cnic'] ?? item['Owner_CNIC'] ?? item['ownerCnic'] ?? item['cnic'] ?? 'N/A',
      phone_no: item['phone_no'] ?? item['Phone_No'] ?? item['phoneNo'] ?? item['phone'] ?? item['mobile'] ?? 'N/A',
      alternative_phone_no: item['alternative_phone_no'] ?? item['Alternative_Phone_No'] ?? item['alternativePhoneNo'] ?? item['alt_phone'] ?? 'N/A',
      shop_date: item['shop_date'] != null
          ? DateTime.tryParse(item['shop_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      shop_time: item['shop_time'] != null
          ? DateTime.tryParse(item['shop_time'].toString()) ?? DateTime.now()
          : DateTime.now(),
      user_id: item['user_id'] ?? item['User_Id'] ?? item['userId'] ?? user_id,
      posted: item['posted'] is int ? item['posted'] : int.tryParse(item['posted']?.toString() ?? '0') ?? 0,
      latitude: item['latitude'] ?? item['Latitude'] ?? item['lat'] ?? '0.0',
      longitude: item['longitude'] ?? item['Longitude'] ?? item['lng'] ?? '0.0',
    );
  }

  List<AddShopModel> get filteredShops {
    if (searchQuery.isEmpty) return shops;

    return shops.where((shop) {
      final shopName = shop.shop_name?.toString().toLowerCase() ?? '';
      final ownerName = shop.owner_name?.toString().toLowerCase() ?? '';
      final city = shop.city?.toString().toLowerCase() ?? '';
      final phone = shop.phone_no?.toString().toLowerCase() ?? '';
      final shopId = shop.shop_id?.toString().toLowerCase() ?? '';
      final query = searchQuery.toLowerCase();

      return shopName.contains(query) ||
          ownerName.contains(query) ||
          city.contains(query) ||
          phone.contains(query) ||
          shopId.contains(query);
    }).toList();
  }

  void showShopDetails(AddShopModel shop) {
    setState(() {
      selectedShop = shop;
    });

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const Text(
              'Shop Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Shop ID:', shop.shop_id ?? 'N/A'),
                    _buildDetailRow('Shop Name:', shop.shop_name ?? 'N/A'),
                    _buildDetailRow('City:', shop.city ?? 'N/A'),
                    _buildDetailRow('Address:', shop.shop_address ?? 'N/A'),
                    _buildDetailRow('Live Address:', shop.shop_live_address ?? 'N/A'),
                    _buildDetailRow('Owner Name:', shop.owner_name ?? 'N/A'),
                    _buildDetailRow('Owner CNIC:', shop.owner_cnic ?? 'N/A'),
                    _buildDetailRow('Phone No:', shop.phone_no ?? 'N/A'),
                    _buildDetailRow('Alt. Phone:', shop.alternative_phone_no ?? 'N/A'),
                    _buildDetailRow('User ID:', shop.user_id ?? 'N/A'),
                    _buildDetailRow('Date:', shop.shop_date != null
                        ? '${shop.shop_date!.day}/${shop.shop_date!.month}/${shop.shop_date!.year}'
                        : 'N/A'),
                    _buildDetailRow('Time:', shop.shop_time != null
                        ? '${shop.shop_time!.hour}:${shop.shop_time!.minute}'
                        : 'N/A'),
                    // _buildDetailRow('Status:', shop.posted == 1 ? '✅ Posted' : '⏳ Pending'),
                    _buildDetailRow('Latitude:', shop.latitude?.toString() ?? 'N/A'),
                    _buildDetailRow('Longitude:', shop.longitude?.toString() ?? 'N/A'),

                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: shop.posted == 1 ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: shop.posted == 1 ? Colors.green.shade200 : Colors.orange.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Shop Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: shop.posted == 1 ? Colors.green : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                shop.posted == 1 ? 'Successfully Posted' : 'Pending Sync',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          Icon(
                            shop.posted == 1 ? Icons.cloud_done : Icons.cloud_upload,
                            color: shop.posted == 1 ? Colors.green : Colors.orange,
                            size: 30,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (shop.latitude != null && shop.longitude != null &&
                        shop.latitude != '0.0' && shop.longitude != '0.0')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location Coordinates:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.blue, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  'Lat: ${shop.latitude}, Lng: ${shop.longitude}',
                                  style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop Records Report',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchShopRecords,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.grey[50],
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by shop name, owner, city, phone...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // Statistics Cards


          // Main content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading shop records...'),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Failed to load shop records',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchShopRecords,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (shops.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No shop records found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: fetchShopRecords,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final displayShops = filteredShops;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
                  (states) => Colors.blueGrey.shade50,
            ),
            columnSpacing: 16,
            horizontalMargin: 8,
            columns: const [
              DataColumn(label: Text('Shop ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Shop Name', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Owner', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('City', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('View', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: displayShops.map((shop) {
              final isPosted = shop.posted == 1;

              return DataRow(
                cells: [
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        shop.shop_id ?? 'N/A',
                        style: const TextStyle(fontSize: 11, fontFamily: 'Monospace'),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        shop.shop_name ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 80,
                      child: Text(
                        shop.owner_name ?? 'N/A',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(shop.city ?? 'N/A')),
                  DataCell(
                    SizedBox(
                      width: 100,
                      child: Text(
                        shop.phone_no ?? 'N/A',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPosted ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPosted ? Icons.check_circle : Icons.pending,
                            size: 14,
                            color: isPosted ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPosted ? 'Posted' : 'Pending',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isPosted ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility, size: 18, color: Colors.blue),
                      onPressed: () => showShopDetails(shop),
                      tooltip: 'View Details',
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}