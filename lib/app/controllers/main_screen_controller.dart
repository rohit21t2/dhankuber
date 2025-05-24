import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:flutter/material.dart'; // Added for Widget type
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import '../ui/pages/home_page.dart';
import '../ui/pages/comparison_page.dart';
import '../ui/pages/portfolio_page.dart';
import '../ui/pages/payments_page.dart';
import '../ui/pages/profile_page.dart';

class MainScreenController extends GetxController {
  var currentIndex = 0.obs;

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
    return formatter.format(now);
  }

  // Getter for the list of pages corresponding to the bottom navigation tabs
  List<Widget> get pages => [
    const HomePage(),
    const ComparisonPage(),
    const PortfolioPage(),
    const PaymentsPage(),
    const ProfilePage(),
  ];

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('MainScreenController initialized at ${_getFormattedTime()}');
    }
  }

  void changeTabIndex(int index) {
    if (kDebugMode) {
      print('Changing tab index to $index at ${_getFormattedTime()}');
    }
    currentIndex.value = index;
  }
}