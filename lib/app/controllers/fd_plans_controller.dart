import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class FDPlansController extends GetxController {
  var isLoading = false.obs;
  var allFDPlans = <Map<String, dynamic>>[].obs; // Explicitly typed
  var trendingPlans = <Map<String, dynamic>>[].obs; // Explicitly typed
  var goalBasedPlans = <Map<String, dynamic>>[].obs; // Explicitly typed
  var filteredPlans = <Map<String, dynamic>>[].obs; // Explicitly typed
  var selectedCategory = ''.obs;
  var selectedGoal = 'Education'.obs;
  var searchQuery = ''.obs;

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
      print('FDPlansController initialized at ${_getFormattedTime()}');
    }
    fetchAllFDPlans();
    fetchTrendingPlans();
    fetchGoalBasedPlans();
    // Initialize filteredPlans with all plans
    filteredPlans.assignAll(allFDPlans);
  }

  Future<void> fetchAllFDPlans() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Fetching all FD plans at ${_getFormattedTime()}');
    }
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('fixed_deposits')
          .orderBy('interestRate', descending: true)
          .get();
      allFDPlans.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      // Update filteredPlans after fetching all plans
      filteredPlans.assignAll(allFDPlans);
      if (kDebugMode) {
        print('All FD plans fetched: ${allFDPlans.length} at ${_getFormattedTime()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all FD plans: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load FD plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTrendingPlans() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Fetching trending FD plans at ${_getFormattedTime()}');
    }
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('fixed_deposits')
          .where('trending', isEqualTo: true)
          .orderBy('popularity', descending: true)
          .get();
      trendingPlans.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      if (kDebugMode) {
        print('Trending FD plans fetched: ${trendingPlans.length} at ${_getFormattedTime()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching trending FD plans: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load trending FD plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGoalBasedPlans() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Fetching goal-based FD plans for goal: ${selectedGoal.value} at ${_getFormattedTime()}');
    }
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('fixed_deposits')
          .where('goal', isEqualTo: selectedGoal.value)
          .orderBy('interestRate', descending: true)
          .get();
      goalBasedPlans.value = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      if (kDebugMode) {
        print('Goal-based FD plans fetched: ${goalBasedPlans.length} at ${_getFormattedTime()}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching goal-based FD plans: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load goal-based FD plans: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchPlans(String query) {
    searchQuery.value = query.toLowerCase();
    if (kDebugMode) {
      print('Searching FD plans with query: $query at ${_getFormattedTime()}');
    }
    if (query.isEmpty) {
      filteredPlans.assignAll(allFDPlans);
      if (selectedCategory.value.isNotEmpty) {
        filterPlans(selectedCategory.value);
      }
    } else {
      filteredPlans.value = allFDPlans.where((plan) {
        final bank = (plan['bank'] ?? '').toLowerCase();
        final planName = (plan['plan'] ?? '').toLowerCase();
        return bank.contains(searchQuery.value) || planName.contains(searchQuery.value);
      }).toList();
      if (selectedCategory.value.isNotEmpty) {
        filterPlans(selectedCategory.value);
      }
    }
    if (kDebugMode) {
      print('Search results: ${filteredPlans.length} plans found at ${_getFormattedTime()}');
    }
  }

  void filterPlans(String category) {
    selectedCategory.value = category;
    if (kDebugMode) {
      print('Filtering FD plans by category: $category at ${_getFormattedTime()}');
    }
    if (category.isEmpty) {
      filteredPlans.assignAll(allFDPlans);
      if (searchQuery.value.isNotEmpty) {
        searchPlans(searchQuery.value);
      }
    } else {
      filteredPlans.value = allFDPlans.where((plan) {
        final categories = (plan['categories'] as List<dynamic>?)?.cast<String>() ?? [];
        return categories.contains(category);
      }).toList();
      if (searchQuery.value.isNotEmpty) {
        searchPlans(searchQuery.value);
      }
    }
    if (kDebugMode) {
      print('Filtered plans: ${filteredPlans.length} plans found for category $category at ${_getFormattedTime()}');
    }
  }

  void selectGoal(String goal) {
    selectedGoal.value = goal;
    if (kDebugMode) {
      print('Selected goal: $goal at ${_getFormattedTime()}');
    }
    fetchGoalBasedPlans();
  }

  List<Map<String, dynamic>> getPlansByGoal(String goal) {
    if (kDebugMode) {
      print('Getting plans for goal: $goal at ${_getFormattedTime()}');
    }
    return goalBasedPlans
        .where((plan) => (plan['goal'] ?? '') == goal)
        .toList()
        .cast<Map<String, dynamic>>();
  }
}