import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:firebase_auth/firebase_auth.dart';

class PaymentsController extends GetxController {
  var isLoading = false.obs;
  var paymentHistory = <Map<String, dynamic>>[].obs; // List of payment transactions

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
      print('PaymentsController initialized at ${_getFormattedTime()}');
    }
    fetchPaymentHistory();
  }

  Future<void> fetchPaymentHistory() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Fetching payment history at ${_getFormattedTime()}');
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

      // Fetch payment history from Firestore
      QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .orderBy('timestamp', descending: true)
          .get();

      paymentHistory.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      if (kDebugMode) {
        print('Payment history fetched: ${paymentHistory.length} transactions at ${_getFormattedTime()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching payment history: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load payment history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPaymentHistory() async {
    if (kDebugMode) {
      print('Refreshing payment history at ${_getFormattedTime()}');
    }
    await fetchPaymentHistory();
    Get.snackbar('Success', 'Payment history updated successfully');
  }
}