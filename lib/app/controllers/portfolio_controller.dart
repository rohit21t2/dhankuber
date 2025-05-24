import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:firebase_auth/firebase_auth.dart';

class PortfolioController extends GetxController {
  var isLoading = false.obs;
  var activeInvestments = <Map<String, dynamic>>[].obs; // List of active FD investments
  var totalInvestment = 0.0.obs; // Total invested amount
  var totalReturns = 0.0.obs; // Total expected returns

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
    return formatter.format(now);
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('PortfolioController initialized at ${_getFormattedTime()}');
    }
    fetchPortfolio();
  }

  Future<void> fetchPortfolio() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Fetching portfolio data at ${_getFormattedTime()}');
    }
    try {
      // Get the current user's phone number
      final user = _auth.currentUser;
      if (user == null || user.phoneNumber == null) {
        if (kDebugMode) {
          print('No authenticated user found at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'User not authenticated. Please log in again.');
        return;
      }
      final phoneNumber = user.phoneNumber!;

      // Fetch active investments from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('investments')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'active')
          .get();

      activeInvestments.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      // Calculate total investment and returns
      double investmentSum = 0.0;
      double returnsSum = 0.0;
      for (var investment in activeInvestments) {
        investmentSum += (investment['amount'] as num?)?.toDouble() ?? 0.0;
        returnsSum += (investment['expectedReturns'] as num?)?.toDouble() ?? 0.0;
      }
      totalInvestment.value = investmentSum;
      totalReturns.value = returnsSum;

      if (kDebugMode) {
        print('Portfolio fetched: ${activeInvestments.length} active investments, '
            'Total Investment: ₹$totalInvestment, Total Returns: ₹$totalReturns at ${_getFormattedTime()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching portfolio: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load portfolio: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPortfolio() async {
    if (kDebugMode) {
      print('Refreshing portfolio data at ${_getFormattedTime()}');
    }
    await fetchPortfolio();
    Get.snackbar('Success', 'Portfolio updated successfully');
  }
}