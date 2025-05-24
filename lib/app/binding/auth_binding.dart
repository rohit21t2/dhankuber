import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    print('AuthBinding: Initializing AuthController');
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}