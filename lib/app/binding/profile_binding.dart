import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    print('ProfileBinding: Initializing ProfileController at 11:25 AM IST, May 24, 2025');
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}