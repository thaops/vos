import 'package:get/get.dart';
import 'package:vos_flutter/feature/profile/controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    // Dùng put() thay vì lazyPut() để đảm bảo controller được tạo ngay
    // Chỉ tạo nếu chưa tồn tại để tránh nhiều instance
    if (!Get.isRegistered<ProfileController>()) {
      Get.put<ProfileController>(ProfileController());
    }
  }
}
