import 'package:get/get.dart';
import '../controllers/payments_controller.dart';

class PaymentsBinding extends Bindings {
  @override
  void dependencies() {
    print('PaymentsBinding: Initializing PaymentsController at 11:25 AM IST, May 24, 2025');
    Get.lazyPut<PaymentsController>(() => PaymentsController(), fenix: true);
  }
}