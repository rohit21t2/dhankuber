import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import '../../controllers/main_screen_controller.dart';
import 'home_page.dart';
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Preload SVGs by rendering them offscreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadSvgs();
    });
  }

  void _preloadSvgs() {
    // List of SVG assets to preload
    const svgAssets = [
      'assets/icons/home_selected.svg',
      'assets/icons/portfolio.svg',
      'assets/icons/payments.svg',
      'assets/icons/profile_outline.svg',
    ];

    // Render SVGs offscreen to ensure they are cached
    for (var asset in svgAssets) {
      SvgPicture.asset(
        asset,
        height: 24,
        color: AppColors.primaryBrand, // Preload with a default color
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final MainScreenController controller = Get.find<MainScreenController>();

    return Obx(() => Scaffold(
      body: Stack(
        children: [
          // Main content
          controller.pages[controller.currentIndex.value],
          // Offscreen SVGs for preloading (not visible)
          Positioned(
            left: -1000, // Move offscreen
            child: Opacity(
              opacity: 0.0, // Make invisible
              child: Column(
                children: [
                  SvgPicture.asset('assets/icons/home_selected.svg', height: 24),
                  SvgPicture.asset('assets/icons/portfolio.svg', height: 24),
                  SvgPicture.asset('assets/icons/payments.svg', height: 24),
                  SvgPicture.asset('assets/icons/profile_outline.svg', height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.accentLightGreen,
        currentIndex: controller.currentIndex.value,
        onTap: (index) {
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
              'assets/icons/portfolio.svg',
              color: controller.currentIndex.value == 1
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/payments.svg',
              color: controller.currentIndex.value == 2
                  ? AppColors.primaryBrand
                  : AppColors.secondaryText,
              height: 24,
            ),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/icons/profile_outline.svg',
              color: controller.currentIndex.value == 3
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