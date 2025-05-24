import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/profile_controller.dart';

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}