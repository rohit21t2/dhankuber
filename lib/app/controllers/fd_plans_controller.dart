import 'package:flutter/material.dart'; // Added for RangeValues
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'home_controller.dart';

class FDPlansController extends GetxController {
  var isLoading = false.obs;

  // Sorting and Filtering Variables
  var sortBy = 'Highest Return'.obs; // Default sort by Highest Return
  var tenureRange = Rx<RangeValues>(const RangeValues(12, 60)); // Tenure range in months (default: 12 to 60 months)
  var returnRange = Rx<RangeValues>(const RangeValues(7.0, 9.5)); // Return range in % (default: 7.0% to 9.5%)
  var taxSavingOnly = false.obs; // Filter for tax-saving FDs
  var seniorCitizenRate = false.obs; // Filter for senior citizen rates
  var filteredFDs = <Map<String, dynamic>>[].obs; // Filtered FDs list

  // Reference to HomeController to access allFDs
  late HomeController homeController;

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
    return formatter.format(now); // e.g., 10:27 PM IST, May 25, 2025
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('FDPlansController initialized at ${_getFormattedTime()}');
    }
    homeController = Get.find<HomeController>();
    applyFiltersAndSort(); // Initialize with default sorting and filtering
  }

  // Apply sorting and filtering to allFDs
  void applyFiltersAndSort() {
    var fds = List<Map<String, dynamic>>.from(homeController.allFDs);

    // Apply Filters
    fds = fds.where((fd) {
      // Tenure Range Filter
      bool tenureFilter = fd['tenureMonths'] >= tenureRange.value.start &&
          fd['tenureMonths'] <= tenureRange.value.end;

      // Return Range Filter
      bool returnFilter = fd['interestRateValue'] >= returnRange.value.start &&
          fd['interestRateValue'] <= returnRange.value.end;

      // Tax Saving Only Filter
      bool taxFilter = taxSavingOnly.value ? fd['taxSaving'] == true : true;

      // Senior Citizen Rate Filter
      bool seniorFilter = seniorCitizenRate.value ? fd['seniorCitizenRate'] == true : true;

      return tenureFilter && returnFilter && taxFilter && seniorFilter;
    }).toList();

    // Apply Sorting
    if (sortBy.value == 'Highest Return') {
      fds.sort((a, b) => b['interestRateValue'].compareTo(a['interestRateValue']));
    } else if (sortBy.value == 'Shortest Tenure') {
      fds.sort((a, b) => a['tenureMonths'].compareTo(b['tenureMonths']));
    }

    filteredFDs.assignAll(fds);
  }

  // Update tenure range and reapply filters
  void updateTenureRange(RangeValues values) {
    tenureRange.value = values;
    applyFiltersAndSort();
  }

  // Update return range and reapply filters
  void updateReturnRange(RangeValues values) {
    returnRange.value = values;
    applyFiltersAndSort();
  }

  // Update tax saving filter and reapply filters
  void toggleTaxSaving(bool value) {
    taxSavingOnly.value = value;
    applyFiltersAndSort();
  }

  // Update senior citizen rate filter and reapply filters
  void toggleSeniorCitizenRate(bool value) {
    seniorCitizenRate.value = value;
    applyFiltersAndSort();
  }

  // Update sort option and reapply filters
  void updateSortBy(String? value) {
    if (value != null) {
      sortBy.value = value;
      applyFiltersAndSort();
    }
  }
}