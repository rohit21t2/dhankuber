import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/main_screen_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/home_controller.dart'; // Added
import '../controllers/fd_plans_controller.dart'; // Added
import '../controllers/portfolio_controller.dart'; // Added
import '../controllers/payments_controller.dart'; // Added
import '../controllers/notification_controller.dart'; // Added
import '../controllers/comparison_controller.dart'; // Added

class MainScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainScreenController>(() => MainScreenController(), fenix: true);
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<FDPlansController>(() => FDPlansController(), fenix: true);
    Get.lazyPut<PortfolioController>(() => PortfolioController(), fenix: true);
    Get.lazyPut<PaymentsController>(() => PaymentsController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<ComparisonController>(() => ComparisonController(), fenix: true);
  }
}