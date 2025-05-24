import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    print('HomeBinding: Initializing HomeController');
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
  }
}