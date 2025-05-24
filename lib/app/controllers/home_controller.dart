import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class HomeController extends GetxController {
  var isLoading = false.obs;
  var recommendedFDs = [].obs;
  var trendingFDs = [].obs;
  var goalBasedFDs = [].obs;
  var notifications = [].obs; // Added for notifications

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      print('HomeController initialized at ${_getFormattedTime()}');
    }
    fetchData();
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Fetching data at ${_getFormattedTime()}');
    }
    try {
      // Fetch Recommended FDs
      QuerySnapshot recommendedSnapshot = await _firestore
          .collection('fixed_deposits')
          .where('recommended', isEqualTo: true)
          .limit(5)
          .get();
      recommendedFDs.value = recommendedSnapshot.docs.map((doc) => doc.data()).toList();
      if (kDebugMode) {
        print('Recommended FDs fetched: ${recommendedFDs.length} at ${_getFormattedTime()}');
      }

      // Fetch Trending FDs
      QuerySnapshot trendingSnapshot = await _firestore
          .collection('fixed_deposits')
          .orderBy('popularity', descending: true)
          .limit(5)
          .get();
      trendingFDs.value = trendingSnapshot.docs.map((doc) => doc.data()).toList();
      if (kDebugMode) {
        print('Trending FDs fetched: ${trendingFDs.length} at ${_getFormattedTime()}');
      }

      // Fetch Goal-Based FDs
      QuerySnapshot goalBasedSnapshot = await _firestore
          .collection('fixed_deposits')
          .where('goalBased', isEqualTo: true)
          .limit(5)
          .get();
      goalBasedFDs.value = goalBasedSnapshot.docs.map((doc) => doc.data()).toList();
      if (kDebugMode) {
        print('Goal-Based FDs fetched: ${goalBasedFDs.length} at ${_getFormattedTime()}');
      }

      // Fetch Notifications (mock data for now, replace with actual Firestore query)
      // Assuming a 'notifications' collection with fields: title, message, timestamp
      try {
        QuerySnapshot notificationsSnapshot = await _firestore
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();
        notifications.value = notificationsSnapshot.docs.map((doc) => doc.data()).toList();
        if (kDebugMode) {
          print('Notifications fetched: ${notifications.length} at ${_getFormattedTime()}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching notifications from Firestore: $e at ${_getFormattedTime()}');
        }
        // Mock data as a fallback if Firestore query fails or isn't set up
        notifications.value = [
          {
            'title': 'Welcome to Dhankuber!',
            'message': 'Start exploring fixed deposits to grow your wealth.',
            'timestamp': Timestamp.now(),
          },
          {
            'title': 'New FD Available',
            'message': 'Check out the latest fixed deposit with 8% interest!',
            'timestamp': Timestamp.now(),
          },
        ];
        if (kDebugMode) {
          print('Using mock notifications data: ${notifications.length} items at ${_getFormattedTime()}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}