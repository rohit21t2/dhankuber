import 'package:get/get.dart';
import 'fd_plans_controller.dart'; // Import FDPlansController to access allFDs

class GoalBasedPlansController extends GetxController {
  // Goal-Based FDs - Categorized using data from FDPlansController
  final RxList<Map<String, dynamic>> goalBasedFDs = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _categorizeFDs();
  }

  void _categorizeFDs() {
    // Get FDPlansController instance
    final FDPlansController fdPlansController = Get.find<FDPlansController>();
    final List<Map<String, dynamic>> allFDs = fdPlansController.allFDs;

    // Categorize FDs into goal-based categories
    List<Map<String, dynamic>> shortTermGoals = [];
    List<Map<String, dynamic>> mediumTermGoals = [];
    List<Map<String, dynamic>> longTermGoals = [];
    List<Map<String, dynamic>> taxSavingGoals = [];

    for (var fd in allFDs) {
      final tenure = fd['tenureMonths'] as int;

      if (fd['taxSaving'] == true) {
        taxSavingGoals.add({
          'goalName': 'Tax-Saving FD',
          'expectedReturn': fd['interestRate'],
          'tenure': fd['plan'],
          'duration': fd['plan'],
          'bank': fd['bank'],
          'issuerType': fd['issuerType'],
        });
      } else if (tenure <= 24) { // 1-2 years
        shortTermGoals.add({
          'goalName': tenure <= 12 ? 'Gadgets/Vehicle Purchase' : 'Emergency Fund',
          'expectedReturn': fd['interestRate'],
          'tenure': fd['plan'],
          'duration': fd['plan'],
          'bank': fd['bank'],
          'issuerType': fd['issuerType'],
        });
      } else if (tenure > 24 && tenure <= 36) { // 2-3 years
        mediumTermGoals.add({
          'goalName': 'Down Payment for House',
          'expectedReturn': fd['interestRate'],
          'tenure': fd['plan'],
          'duration': fd['plan'],
          'bank': fd['bank'],
          'issuerType': fd['issuerType'],
        });
      } else if (tenure > 36) { // 3+ years
        longTermGoals.add({
          'goalName': tenure == 60 ? 'Retirement Fund' : 'Wealth Creation',
          'expectedReturn': fd['interestRate'],
          'tenure': fd['plan'],
          'duration': fd['plan'],
          'bank': fd['bank'],
          'issuerType': fd['issuerType'],
        });
      }
    }

    goalBasedFDs.assignAll([
      {'category': 'Short-Term Goal FDs (1-2 years)', 'goals': shortTermGoals},
      {'category': 'Medium-Term Goal FDs (2-3 years)', 'goals': mediumTermGoals},
      {'category': 'Long-Term Goal FDs (3+ years)', 'goals': longTermGoals},
      {'category': 'Tax-Saving FDs (5 years lock-in)', 'goals': taxSavingGoals},
    ]);
  }
}