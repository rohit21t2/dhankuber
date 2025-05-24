import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import '../../controllers/main_screen_controller.dart';
import 'home_page.dart';
import 'comparison_page.dart';
import 'portfolio_page.dart';
import 'payments_page.dart';
import 'profile_page.dart';
import '../../utils/colors.dart';

// Utility function to format the current time
String getFormattedTime() {
  final now = DateTime.now();
  final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
  return formatter.format(now);
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print('MainScreen: Building at ${getFormattedTime()}');
    final MainScreenController controller = Get.find<MainScreenController>();

    return Obx(() => Scaffold(
      body: controller.pages[controller.currentIndex.value],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.accentLightGreen,
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
          print('MainScreen: BottomNavigationBar tapped at index $index at 03:55 PM IST, May 24, 2025');
          controller.currentIndex.value = index;
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBrand,
        unselectedItemColor: AppColors.secondaryText,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/home_selected.svg',
              color: controller.currentIndex.value == 0
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/compare.svg',
              color: controller.currentIndex.value == 1
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Comparison',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/portfolio.svg',
              color: controller.currentIndex.value == 2
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/payments.svg',
              color: controller.currentIndex.value == 3
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile_outline.svg',
              color: controller.currentIndex.value == 4
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Profile',
          ),
        ],
      ),
    ));
  }
}