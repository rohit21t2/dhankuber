import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Added for date formatting

class FDPlan {
  final String bankName;
  final double interestRate;
  final int tenureMonths;
  final String issuerType; // Added issuerType
  final bool isTaxSaving; // Added isTaxSaving

  FDPlan({
    required this.bankName,
    required this.interestRate,
    required this.tenureMonths,
    required this.issuerType,
    required this.isTaxSaving,
  });
}

class ComparisonController extends GetxController {
  var fdPlans = <FDPlan>[].obs;
  var selectedFDPlans = List<FDPlan?>.filled(3, null).obs; // For 3 FD slots

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
    return formatter.format(now);
  }

  @override
  void onInit() {
    super.onInit();
    _loadFDPlans();
    if (kDebugMode) {
      print('ComparisonController initialized at ${_getFormattedTime()}');
    }
  }

  void _loadFDPlans() {
    // Mock data for FD plans
    fdPlans.addAll([
      FDPlan(
        bankName: 'Suryoday Small Finance Bank',
        interestRate: 9.1,
        tenureMonths: 12,
        issuerType: 'Bank',
        isTaxSaving: false,
      ),
      FDPlan(
        bankName: 'Bajaj Finance Ltd.',
        interestRate: 8.5,
        tenureMonths: 24,
        issuerType: 'NBFC',
        isTaxSaving: true,
      ),
      FDPlan(
        bankName: 'HDFC Bank',
        interestRate: 7.0,
        tenureMonths: 36,
        issuerType: 'Bank',
        isTaxSaving: false,
      ),
      FDPlan(
        bankName: 'ICICI Bank',
        interestRate: 6.8,
        tenureMonths: 18,
        issuerType: 'Bank',
        isTaxSaving: true,
      ),
    ]);
    if (kDebugMode) {
      print('FD Plans loaded at ${_getFormattedTime()}: ${fdPlans.length} plans');
    }
  }

  List<FDPlan> getAvailableFDs(int slotIndex) {
    // Return FD plans that are not selected in other slots
    return fdPlans.where((plan) {
      return !selectedFDPlans.any((selected) =>
      selected != null && selected.bankName == plan.bankName && selected != selectedFDPlans[slotIndex]);
    }).toList();
  }

  void updateSelectedFD(int slotIndex, FDPlan plan) {
    selectedFDPlans[slotIndex] = plan;
    if (kDebugMode) {
      print('FD Plan selected at slot $slotIndex at ${_getFormattedTime()}: ${plan.bankName}');
    }
    selectedFDPlans.refresh();
  }

  void clearSelection(int slotIndex) {
    selectedFDPlans[slotIndex] = null;
    if (kDebugMode) {
      print('FD Plan cleared at slot $slotIndex at ${_getFormattedTime()}');
    }
    selectedFDPlans.refresh();
  }

  void clearSelections() {
    selectedFDPlans.value = List<FDPlan?>.filled(3, null);
    if (kDebugMode) {
      print('All FD selections cleared at ${_getFormattedTime()}');
    }
    selectedFDPlans.refresh();
  }
}