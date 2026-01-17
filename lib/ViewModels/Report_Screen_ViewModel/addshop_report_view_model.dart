import 'package:get/get.dart';
import '../../Models/add_shop_model.dart';
import '../../Repositories/add_shop_repository.dart';

class AddShopDashboardVM extends GetxController {
  final AddShopRepository repo = Get.find<AddShopRepository>();

  var shops = <AddShopModel>[].obs; // List of shops
  var isLoading = true.obs;         // Loading indicator
  var error = ''.obs;               // Error string

  @override
  void onInit() {
    fetchDashboard();
    super.onInit();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading(true);
      error(''); // Clear previous error

      // GET API call
      shops.value = await repo.getShopDashboard();
    } catch (e) {
      // Convert Object / Exception to String
      error(e.toString());
    } finally {
      isLoading(false);
    }
  }
}
