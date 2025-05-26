import 'package:flutter/material.dart'; // Added for RangeValues
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class FDPlansController extends GetxController {
  var isLoading = false.obs;

  // All FDs - Moved from HomeController with minDeposit and fdType fields
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
      'minDeposit': 10000,
      'fdType': 'SeniorCitizen',
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
      'minDeposit': 5000,
      'fdType': 'Regular',
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
      'minDeposit': 60000,
      'fdType': 'TaxSaving',
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
      'minDeposit': 25000,
      'fdType': 'NRE_NRO',
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
      'minDeposit': 1500,
      'fdType': 'Regular',
    },
  ].obs;

  // Sorting and Filtering Variables (Applied Values)
  var sortBy = 'Highest Return'.obs; // Default sort by Highest Return
  var tenureRange = Rx<RangeValues>(const RangeValues(12, 60)); // Tenure range in months (default: 12 to 60 months)
  var returnRange = Rx<RangeValues>(const RangeValues(7.0, 9.5)); // Return range in % (default: 7.0% to 9.5%)
  var taxSavingOnly = false.obs; // Filter for tax-saving FDs
  var seniorCitizenRate = false.obs; // Filter for senior citizen rates
  var selectedFDTypes = <String>{'Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO'}.obs; // Multi-selection for FD types
  var selectedDepositRanges = <String>{'1000-5000', '5001-50000', '50001+'}.obs; // Multi-selection for deposit ranges
  var filteredFDs = <Map<String, dynamic>>[].obs; // Filtered FDs list

  // Temporary Variables for Filters and Sorting (Not Applied Until "Apply Filters" is Clicked)
  var tempSortBy = 'Highest Return'.obs; // Temporary sort by
  var tempTenureRange = Rx<RangeValues>(const RangeValues(12, 60)); // Temporary tenure range
  var tempReturnRange = Rx<RangeValues>(const RangeValues(7.0, 9.5)); // Temporary return range
  var tempTaxSavingOnly = false.obs; // Temporary tax-saving filter
  var tempSeniorCitizenRate = false.obs; // Temporary senior citizen rate filter
  var tempSelectedFDTypes = <String>{'Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO'}.obs; // Temporary FD types
  var tempSelectedDepositRanges = <String>{'1000-5000', '5001-50000', '50001+'}.obs; // Temporary deposit ranges

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
    return formatter.format(now); // e.g., 10:58 PM IST, May 25, 2025
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('FDPlansController initialized at ${_getFormattedTime()}');
    }
    resetFiltersAndSort(); // Initialize with unfiltered and unsorted data
  }

  @override
  void onClose() {
    resetFiltersAndSort(); // Reset filters and sorting when navigating away
    super.onClose();
  }

  // Method to provide a preview of allFDs for HomePage
  List<Map<String, dynamic>> getAllFDsPreview(int count) {
    return allFDs.take(count).toList();
  }

  // Reset all filters and sorting to default (unfiltered and unsorted)
  void resetFiltersAndSort() {
    // Reset applied values
    sortBy.value = 'Highest Return';
    tenureRange.value = const RangeValues(12, 60);
    returnRange.value = const RangeValues(7.0, 9.5);
    taxSavingOnly.value = false;
    seniorCitizenRate.value = false;
    selectedFDTypes.clear();
    selectedFDTypes.addAll(['Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO']);
    selectedDepositRanges.clear();
    selectedDepositRanges.addAll(['1000-5000', '5001-50000', '50001+']);

    // Reset temporary values
    tempSortBy.value = 'Highest Return';
    tempTenureRange.value = const RangeValues(12, 60);
    tempReturnRange.value = const RangeValues(7.0, 9.5);
    tempTaxSavingOnly.value = false;
    tempSeniorCitizenRate.value = false;
    tempSelectedFDTypes.clear();
    tempSelectedFDTypes.addAll(['Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO']);
    tempSelectedDepositRanges.clear();
    tempSelectedDepositRanges.addAll(['1000-5000', '5001-50000', '50001+']);

    // Set filteredFDs to original unfiltered and unsorted list
    filteredFDs.assignAll(allFDs);
  }

  // Apply sorting and filtering to allFDs using applied values
  void applyFiltersAndSort() {
    var fds = List<Map<String, dynamic>>.from(allFDs); // Use local allFDs

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

      // FD Type Filter (multi-selection)
      bool fdTypeFilter = selectedFDTypes.contains(fd['fdType']);

      // Minimum Deposit Amount Filter (multi-selection)
      bool depositFilter = false;
      double minDeposit = fd['minDeposit'].toDouble();
      if (selectedDepositRanges.contains('1000-5000') && minDeposit >= 1000 && minDeposit <= 5000) {
        depositFilter = true;
      }
      if (selectedDepositRanges.contains('5001-50000') && minDeposit >= 5001 && minDeposit <= 50000) {
        depositFilter = true;
      }
      if (selectedDepositRanges.contains('50001+') && minDeposit >= 50001) {
        depositFilter = true;
      }

      return tenureFilter && returnFilter && taxFilter && seniorFilter && fdTypeFilter && depositFilter;
    }).toList();

    // Apply Sorting
    if (sortBy.value == 'Highest Return') {
      fds.sort((a, b) => b['interestRateValue'].compareTo(a['interestRateValue']));
    } else if (sortBy.value == 'Shortest Tenure') {
      fds.sort((a, b) => a['tenureMonths'].compareTo(b['tenureMonths']));
    } else if (sortBy.value == 'Highest Tenure') {
      fds.sort((a, b) => b['tenureMonths'].compareTo(a['tenureMonths']));
    } else if (sortBy.value == 'Minimum Deposit Amount') {
      fds.sort((a, b) => a['minDeposit'].compareTo(b['minDeposit']));
    }

    filteredFDs.assignAll(fds);
  }

  // Apply temporary filter and sort values when "Apply Filters" is clicked
  void applyTempFiltersAndSort() {
    sortBy.value = tempSortBy.value;
    tenureRange.value = tempTenureRange.value;
    returnRange.value = tempReturnRange.value;
    taxSavingOnly.value = tempTaxSavingOnly.value;
    seniorCitizenRate.value = tempSeniorCitizenRate.value;
    selectedFDTypes.clear();
    selectedFDTypes.addAll(tempSelectedFDTypes);
    selectedDepositRanges.clear();
    selectedDepositRanges.addAll(tempSelectedDepositRanges);
    applyFiltersAndSort();
  }

  // Update temporary tenure range
  void updateTempTenureRange(RangeValues values) {
    tempTenureRange.value = values;
  }

  // Update temporary return range
  void updateTempReturnRange(RangeValues values) {
    tempReturnRange.value = values;
  }

  // Update temporary tax saving filter
  void toggleTempTaxSaving(bool value) {
    tempTaxSavingOnly.value = value;
  }

  // Update temporary senior citizen rate filter
  void toggleTempSeniorCitizenRate(bool value) {
    tempSeniorCitizenRate.value = value;
  }

  // Update temporary FD type filter
  void toggleTempFDType(String type, bool value) {
    if (value) {
      tempSelectedFDTypes.add(type);
    } else {
      tempSelectedFDTypes.remove(type);
    }
    // Ensure at least one FD type is selected
    if (tempSelectedFDTypes.isEmpty) {
      tempSelectedFDTypes.addAll(['Regular', 'TaxSaving', 'SeniorCitizen', 'NRE_NRO']);
    }
  }

  // Update temporary deposit range filter
  void toggleTempDepositRange(String range, bool value) {
    if (value) {
      tempSelectedDepositRanges.add(range);
    } else {
      tempSelectedDepositRanges.remove(range);
    }
    // Ensure at least one range is selected
    if (tempSelectedDepositRanges.isEmpty) {
      tempSelectedDepositRanges.addAll(['1000-5000', '5001-50000', '50001+']);
    }
  }

  // Update temporary sort option
  void updateTempSortBy(String? value) {
    if (value != null) {
      tempSortBy.value = value;
    }
  }
}