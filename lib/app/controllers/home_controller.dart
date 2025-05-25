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

  // All FDs - Updated with specified Banks and NBFCs
  final RxList<Map<String, dynamic>> allFDs = [
    {
      'bank': 'Suryoday Small Finance Bank',
      'plan': '12 Months',
      'tenureMonths': 12,
      'interestRate': '9.10% p.a.',
      'interestRateValue': 9.10,
      'issuerType': 'Bank',
      'taxSaving': false,
      'seniorCitizenRate': true,
    },
    {
      'bank': 'Unity Small Finance Bank',
      'plan': '24 Months',
      'tenureMonths': 24,
      'interestRate': '8.50% p.a.',
      'interestRateValue': 8.50,
      'issuerType': 'Bank',
      'taxSaving': false,
      'seniorCitizenRate': true,
    },
    {
      'bank': 'Shriram Finance Limited',
      'plan': '60 Months',
      'tenureMonths': 60,
      'interestRate': '8.20% p.a.',
      'interestRateValue': 8.20,
      'issuerType': 'NBFC',
      'taxSaving': true,
      'seniorCitizenRate': false,
    },
    {
      'bank': 'Bajaj Finance Limited',
      'plan': '36 Months',
      'tenureMonths': 36,
      'interestRate': '8.60% p.a.',
      'interestRateValue': 8.60,
      'issuerType': 'NBFC',
      'taxSaving': false,
      'seniorCitizenRate': true,
    },
    {
      'bank': 'Mahindra Finance Ltd',
      'plan': '18 Months',
      'tenureMonths': 18,
      'interestRate': '8.30% p.a.',
      'interestRateValue': 8.30,
      'issuerType': 'NBFC',
      'taxSaving': false,
      'seniorCitizenRate': false,
    },
  ].obs;

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
    return formatter.format(now); // e.g., 10:33 PM IST, May 25, 2025
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('HomeController initialized at ${_getFormattedTime()}');
    }
  }
}