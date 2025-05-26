import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    print('ProfileBinding: Initializing ProfileController at 08:32 PM IST, May 26, 2025');
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
  }
}