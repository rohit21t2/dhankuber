import 'package:get/get.dart';

class GoalBasedPlansController extends GetxController {
  // Goal-Based FDs - Updated with new categories and goals
  final RxList<Map<String, dynamic>> goalBasedFDs = [
    // Short-Term Goal FDs (1-3 years)
    {
      'category': 'Short-Term Goal FDs (1-3 years)',
      'goals': [
        {'goalName': 'Emergency Fund', 'expectedReturn': '7.5% p.a.', 'tenure': '2 years', 'duration': '2 years'},
        {'goalName': 'Vacation Fund', 'expectedReturn': '7.5% p.a.', 'tenure': '3 years', 'duration': '3 years'},
        {'goalName': 'Gadgets/Vehicle Purchase', 'expectedReturn': '7.0% p.a.', 'tenure': '1 year', 'duration': '1 year'},
        {'goalName': 'Wedding Expenses', 'expectedReturn': '7.2% p.a.', 'tenure': '2 years', 'duration': '2 years'},
      ],
    },
    // Medium-Term Goal FDs (3-7 years)
    {
      'category': 'Medium-Term Goal FDs (3-7 years)',
      'goals': [
        {'goalName': 'Higher Education Fund', 'expectedReturn': '8.0% p.a.', 'tenure': '5 years', 'duration': '5 years'},
        {'goalName': 'Down Payment for House', 'expectedReturn': '8.2% p.a.', 'tenure': '4 years', 'duration': '4 years'},
        {'goalName': 'Business Startup Fund', 'expectedReturn': '8.5% p.a.', 'tenure': '6 years', 'duration': '6 years'},
        {'goalName': 'Big Family Event', 'expectedReturn': '8.0% p.a.', 'tenure': '5 years', 'duration': '5 years'},
      ],
    },
    // Long-Term Goal FDs (7+ years)
    {
      'category': 'Long-Term Goal FDs (7+ years)',
      'goals': [
        {'goalName': 'Retirement Fund', 'expectedReturn': '9.0% p.a.', 'tenure': '10 years', 'duration': '10 years'},
        {'goalName': 'Child Marriage/Studies', 'expectedReturn': '8.8% p.a.', 'tenure': '12 years', 'duration': '12 years'},
        {'goalName': 'Wealth Creation', 'expectedReturn': '9.2% p.a.', 'tenure': '15 years', 'duration': '15 years'},
        {'goalName': 'Legacy Planning', 'expectedReturn': '9.0% p.a.', 'tenure': '20 years', 'duration': '20 years'},
      ],
    },
    // Tax-Saving FDs (5 years lock-in)
    {
      'category': 'Tax-Saving FDs (5 years lock-in)',
      'goals': [
        {'goalName': 'Tax-Saving FD', 'expectedReturn': '7.8% p.a.', 'tenure': '5 years', 'duration': '5 years'},
      ],
    },
    // Recurring Deposit Based Goal FDs
    {
      'category': 'Recurring Deposit Based Goal FDs',
      'goals': [
        {'goalName': 'Vacation Fund (RD)', 'expectedReturn': '7.0% p.a.', 'tenure': '3 years', 'duration': '3 years'},
        {'goalName': 'Education Fund (RD)', 'expectedReturn': '7.5% p.a.', 'tenure': '5 years', 'duration': '5 years'},
      ],
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }
}