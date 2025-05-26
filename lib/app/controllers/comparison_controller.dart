import 'package:get/get.dart';

class FDPlan {
  final String bankName;
  final double interestRate;
  final int tenureMonths;
  final int lockInMonths;
  final double rating;
  final int minInvestment;
  final String goal;

  FDPlan({
    required this.bankName,
    required this.interestRate,
    required this.tenureMonths,
    required this.lockInMonths,
    required this.rating,
    required this.minInvestment,
    required this.goal,
  });
}

class ComparisonController extends GetxController {
  var isLoading = false.obs;
  var allFDPlans = <FDPlan>[].obs; // Reactive list of FD plans
  var selectedFDPlans = List<FDPlan?>.filled(3, null).obs; // Reactive list for selected FDs

  @override
  void onInit() {
    super.onInit();
    // Initialize the FD plans data
    allFDPlans.addAll([
      FDPlan(bankName: 'SBI', interestRate: 6.5, tenureMonths: 36, lockInMonths: 36, rating: 4.5, minInvestment: 10000, goal: 'Retirement'),
      FDPlan(bankName: 'HDFC', interestRate: 7.0, tenureMonths: 24, lockInMonths: 24, rating: 4.0, minInvestment: 5000, goal: 'Emergency Fund'),
      FDPlan(bankName: 'ICICI', interestRate: 6.8, tenureMonths: 12, lockInMonths: 12, rating: 4.2, minInvestment: 10000, goal: 'Short-Term'),
      FDPlan(bankName: 'Axis', interestRate: 7.2, tenureMonths: 48, lockInMonths: 48, rating: 4.3, minInvestment: 15000, goal: 'Retirement'),
      FDPlan(bankName: 'Bajaj Finance', interestRate: 8.0, tenureMonths: 36, lockInMonths: 36, rating: 4.8, minInvestment: 25000, goal: 'Retirement'),
      FDPlan(bankName: 'Shriram Finance', interestRate: 8.5, tenureMonths: 60, lockInMonths: 60, rating: 4.7, minInvestment: 20000, goal: 'Retirement'),
      FDPlan(bankName: 'Mahindra Finance', interestRate: 8.1, tenureMonths: 24, lockInMonths: 24, rating: 4.6, minInvestment: 5000, goal: 'Emergency Fund'),
      FDPlan(bankName: 'IndusInd', interestRate: 7.75, tenureMonths: 18, lockInMonths: 18, rating: 4.4, minInvestment: 10000, goal: 'Short-Term'),
      FDPlan(bankName: 'Canara Bank', interestRate: 6.7, tenureMonths: 36, lockInMonths: 36, rating: 4.1, minInvestment: 10000, goal: 'Retirement'),
      FDPlan(bankName: 'Post Office', interestRate: 6.9, tenureMonths: 60, lockInMonths: 60, rating: 4.0, minInvestment: 1000, goal: 'Retirement'),
    ]);
  }

  // Method to get available FDs for a specific dropdown, excluding already selected FDs
  List<FDPlan> getAvailableFDs(int fieldIndex) {
    List<FDPlan?> otherSelections = selectedFDPlans.asMap().entries
        .where((entry) => entry.key != fieldIndex)
        .map((entry) => entry.value)
        .toList();
    return allFDPlans.where((plan) => !otherSelections.contains(plan)).toList();
  }

  // Method to update the selected FD plan for a given index
  void updateSelectedFD(int index, FDPlan? plan) {
    selectedFDPlans[index] = plan;
  }

  // Method to clear a selection
  void clearSelection(int index) {
    selectedFDPlans[index] = null;
  }
}