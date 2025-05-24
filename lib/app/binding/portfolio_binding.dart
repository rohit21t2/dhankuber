import 'package:get/get.dart';
import '../controllers/portfolio_controller.dart';

class PortfolioBinding extends Bindings {
  @override
  void dependencies() {
    print('PortfolioBinding: Initializing PortfolioController at 11:25 AM IST, May 24, 2025');
    Get.lazyPut<PortfolioController>(() => PortfolioController(), fenix: true);
  }
}