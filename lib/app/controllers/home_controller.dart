import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class HomeController extends GetxController {
  // Fixerra FDs (Stories-like Panel) - Increased to 6
  final RxList<Map<String, dynamic>> fixerraFDs = [
    {'title': 'Suryoday Small Finance Bank', 'url': 'https://dhan-kuber.com/fd1'},
    {'title': 'Suryoday Small Finance Bank', 'url': 'https://dhan-kuber.com/fd2'},
    {'title': 'Suryoday Small Finance Bank', 'url': 'https://dhan-kuber.com/fd3'},
    {'title': 'Suryoday Small Finance Bank', 'url': 'https://dhan-kuber.com/fd4'},
    {'title': 'Suryoday Small Finance Bank', 'url': 'https://dhan-kuber.com/fd5'},
    {'title': 'Suryoday Small Finance Bank', 'url': 'https://dhan-kuber.com/fd6'},
  ].obs;

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
    return formatter.format(now); // e.g., 10:45 PM IST, May 25, 2025
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('HomeController initialized at ${_getFormattedTime()}');
    }
  }
}