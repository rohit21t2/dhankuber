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

  // Trending FDs - Show 3 items
  final RxList<Map<String, dynamic>> trendingFDs = [
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
  ].obs;

  // Goal-Based FDs - Show 3 items
  final RxList<Map<String, dynamic>> goalBasedFDs = [
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
  ].obs;

  // All FDs - Show 3 items
  final RxList<Map<String, dynamic>> allFDs = [
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
    {'bank': 'Suryoday Small Finance Bank', 'plan': '12 Months', 'interestRate': '9.10% p.a.', 'issuerType': 'Bank'},
  ].obs;

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
    return formatter.format(now); // e.g., 06:35 PM IST, May 25, 2025
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('HomeController initialized at ${_getFormattedTime()}');
    }
  }
}