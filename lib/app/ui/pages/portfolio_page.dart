import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/portfolio_controller.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PortfolioController controller = Get.find<PortfolioController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Portfolio'),
      body: Obx(() => Stack(
        children: [
          const Center(child: Text('Portfolio Page')),
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