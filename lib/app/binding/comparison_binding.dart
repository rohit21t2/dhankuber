import 'package:get/get.dart';
import '../controllers/comparison_controller.dart';

class ComparisonBinding extends Bindings {
  @override
  void dependencies() {
    print('ComparisonBinding: Initializing ComparisonController');
    Get.lazyPut<ComparisonController>(() => ComparisonController(), fenix: true);
  }
}