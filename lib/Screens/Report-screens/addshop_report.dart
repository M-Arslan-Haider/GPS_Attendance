import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../ViewModels/Report_Screen_ViewModel/addshop_report_view_model.dart';
import '../../Models/add_shop_model.dart';

class AddShopDashboardScreen extends StatelessWidget {
  final AddShopDashboardVM vm = Get.put(AddShopDashboardVM());

  AddShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Shop Dashboard"),
      ),
      body: Obx(() {
        // 1️⃣ Loading state
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2️⃣ Error state
        if (vm.error.value.isNotEmpty) {
          return Center(
            child: Text(
              vm.error.value.toString(),
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3️⃣ No data found
        if (vm.shops.isEmpty) {
          return const Center(
            child: Text("No Shops Found"),
          );
        }

        // 4️⃣ ListView of shops
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: vm.shops.length,
          itemBuilder: (context, index) {
            final AddShopModel shop = vm.shops[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(Icons.store, color: Colors.blue),
                title: Text(
                  shop.shop_name?.toString() ?? "",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Owner: ${shop.owner_name?.toString() ?? ""}"),
                    Text("City: ${shop.city?.toString() ?? ""}"),
                  ],
                ),
                trailing: Text(
                  shop.shop_date?.toString() ?? "",
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
