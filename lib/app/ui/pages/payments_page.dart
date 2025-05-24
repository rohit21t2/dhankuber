import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/payments_controller.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PaymentsController controller = Get.find<PaymentsController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Payments'),
      body: Obx(() => Stack(
        children: [
          const Center(child: Text('Payments Page')),
          if (controller.isLoading.value)
            Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 100,
                height: 100,
              ),
            ),
        ],
      )),
    );
  }
}