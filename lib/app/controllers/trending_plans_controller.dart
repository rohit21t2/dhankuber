import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:flutter/material.dart'; // Added for RangeValues
import 'package:get/get.dart';
import 'fd_plans_controller.dart'; // Import FDPlansController to access allFDs

class TrendingPlansController extends GetxController {
  // All Trending FDs (now sourced from FDPlansController)
  final RxList<Map<String, dynamic>> allTrendingFDs = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredTrendingFDs = <Map<String, dynamic>>[].obs;

  // Temporary variables for filters and sorting
  final Rx<RangeValues> tempTenureRange = const RangeValues(12, 60).obs;
  final Rx<RangeValues> tempReturnRange = const RangeValues(7.0, 9.5).obs;
  final RxBool tempTaxSavingOnly = false.obs;
  final RxBool tempSeniorCitizenRate = false.obs;
  final RxList<String> tempSelectedFDTypes = ['Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO'].obs;
  final RxList<String> tempSelectedDepositRanges = ['1000-5000', '5001-50000', '50001+'].obs;
  final RxString tempSortBy = 'Popularity'.obs; // Default sort by popularity

  @override
  void onInit() {
    super.onInit();
    _initializeTrendingFDs();
    applyTempFiltersAndSort();
  }

  @override
  void onClose() {
    if (kDebugMode) {
      print('TrendingPlansController onClose called');
    }
    resetFiltersAndSort();
    super.onClose();
  }

  void _initializeTrendingFDs() {
    // Get FDPlansController instance
    final FDPlansController fdPlansController = Get.find<FDPlansController>();

    // Use allFDs from FDPlansController, adapting the structure for TrendingPlansController
    allTrendingFDs.assignAll(fdPlansController.allFDs.map((fd) => {
      'bank': fd['bank'],
      'plan': fd['plan'],
      'interestRate': fd['interestRate'],
      'issuerType': fd['issuerType'],
      'taxSaving': fd['taxSaving'],
      'seniorCitizen': fd['seniorCitizenRate'],
      'minimumDeposit': fd['minDeposit'],
      'type': fd['fdType'],
      'popularityScore': _calculatePopularityScore(fd), // Calculate a pseudo-popularity score
    }).toList());

    // Initially sort by popularity
    allTrendingFDs.sort((a, b) => b['popularityScore'].compareTo(a['popularityScore']));
  }

  // Helper method to calculate a pseudo-popularity score based on interest rate and tenure
  int _calculatePopularityScore(Map<String, dynamic> fd) {
    double interestRate = double.tryParse(fd['interestRate'].replaceAll('% p.a.', '')) ?? 0.0;
    int tenure = int.tryParse(fd['plan'].split(' ')[0]) ?? 0;
    // Higher interest rates and shorter tenures are considered more popular
    return ((interestRate * 10) + (60 - tenure)).toInt();
  }

  // Get a preview of trending FDs for HomePage
  Future<List<Map<String, dynamic>>> getTrendingFDsPreview(int count) async {
    // Simulate an async operation (e.g., fetching from a database or API)
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
    return filteredTrendingFDs.take(count).toList();
  }

  // Filter and sort logic
  void applyTempFiltersAndSort() {
    var filtered = allTrendingFDs.where((fd) {
      // Tenure Range Filter
      final tenureStr = fd['plan']?.split(' ')[0] ?? '0';
      final tenure = int.tryParse(tenureStr) ?? 0;
      if (tenure < tempTenureRange.value.start || tenure > tempTenureRange.value.end) return false;

      // Return Range Filter
      final rateStr = fd['interestRate']?.replaceAll('% p.a.', '') ?? '0';
      final rate = double.tryParse(rateStr) ?? 0.0;
      if (rate < tempReturnRange.value.start || rate > tempReturnRange.value.end) return false;

      // Tax Saving Only Filter
      if (tempTaxSavingOnly.value && fd['taxSaving'] != true) return false;

      // Senior Citizen Rate Filter
      if (tempSeniorCitizenRate.value && fd['seniorCitizen'] != true) return false;

      // FD Type Filter
      if (!tempSelectedFDTypes.contains(fd['type'])) return false;

      // Minimum Deposit Amount Filter
      final deposit = fd['minimumDeposit'] as int;
      bool depositMatch = false;
      if (tempSelectedDepositRanges.contains('1000-5000') && deposit >= 1000 && deposit <= 5000) {
        depositMatch = true;
      }
      if (tempSelectedDepositRanges.contains('5001-50000') && deposit > 5000 && deposit <= 50000) {
        depositMatch = true;
      }
      if (tempSelectedDepositRanges.contains('50001+') && deposit > 50000) {
        depositMatch = true;
      }
      if (!depositMatch) return false;

      return true;
    }).toList();

    // Sorting
    if (tempSortBy.value == 'Highest Return') {
      filtered.sort((a, b) {
        final rateA = double.tryParse(a['interestRate'].replaceAll('% p.a.', '')) ?? 0.0;
        final rateB = double.tryParse(b['interestRate'].replaceAll('% p.a.', '')) ?? 0.0;
        return rateB.compareTo(rateA);
      });
    } else if (tempSortBy.value == 'Shortest Tenure') {
      filtered.sort((a, b) {
        final tenureA = int.tryParse(a['plan'].split(' ')[0]) ?? 0;
        final tenureB = int.tryParse(b['plan'].split(' ')[0]) ?? 0;
        return tenureA.compareTo(tenureB);
      });
    } else if (tempSortBy.value == 'Highest Tenure') {
      filtered.sort((a, b) {
        final tenureA = int.tryParse(a['plan'].split(' ')[0]) ?? 0;
        final tenureB = int.tryParse(b['plan'].split(' ')[0]) ?? 0;
        return tenureB.compareTo(tenureA);
      });
    } else if (tempSortBy.value == 'Minimum Deposit Amount') {
      filtered.sort((a, b) {
        final depositA = a['minimumDeposit'] as int;
        final depositB = b['minimumDeposit'] as int;
        return depositA.compareTo(depositB);
      });
    } else if (tempSortBy.value == 'Popularity') {
      filtered.sort((a, b) => b['popularityScore'].compareTo(a['popularityScore']));
    }

    filteredTrendingFDs.assignAll(filtered);
  }

  void updateTempTenureRange(RangeValues values) => tempTenureRange.value = values;
  void updateTempReturnRange(RangeValues values) => tempReturnRange.value = values;
  void toggleTempTaxSaving(bool value) => tempTaxSavingOnly.value = value;
  void toggleTempSeniorCitizenRate(bool value) => tempSeniorCitizenRate.value = value;

  void toggleTempFDType(String type, bool value) {
    if (value) {
      tempSelectedFDTypes.add(type);
    } else {
      tempSelectedFDTypes.remove(type);
    }
  }

  void toggleTempDepositRange(String range, bool value) {
    if (value) {
      tempSelectedDepositRanges.add(range);
    } else {
      tempSelectedDepositRanges.remove(range);
    }
  }

  void updateTempSortBy(String? value) {
    if (value != null) tempSortBy.value = value;
  }

  void resetFiltersAndSort() {
    tempTenureRange.value = const RangeValues(12, 60);
    tempReturnRange.value = const RangeValues(7.0, 9.5);
    tempTaxSavingOnly.value = false;
    tempSeniorCitizenRate.value = false;
    tempSelectedFDTypes.assignAll(['Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO']);
    tempSelectedDepositRanges.assignAll(['1000-5000', '5001-50000', '50001+']);
    tempSortBy.value = 'Popularity';
    applyTempFiltersAndSort();
  }
}