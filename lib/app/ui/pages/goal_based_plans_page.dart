import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/goal_based_plans_controller.dart'; // Updated import
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class GoalBasedPlansPage extends StatefulWidget {
  const GoalBasedPlansPage({super.key});

  @override
  _GoalBasedPlansPageState createState() => _GoalBasedPlansPageState();
}

class _GoalBasedPlansPageState extends State<GoalBasedPlansPage> {
  String? selectedGoalType;
  String? selectedTenure;
  String? selectedInterestRate;
  bool showTaxBenefitOnly = false;

  @override
  Widget build(BuildContext context) {
    final GoalBasedPlansController goalBasedPlansController = Get.find<GoalBasedPlansController>(); // Updated controller

    // Filter logic
    List<Map<String, dynamic>> filteredFDs = goalBasedPlansController.goalBasedFDs;
    if (selectedGoalType != null) {
      filteredFDs = filteredFDs
          .where((category) => category['category'].contains(selectedGoalType))
          .toList();
    }
    if (selectedTenure != null) {
      filteredFDs = filteredFDs.map((category) {
        return {
          'category': category['category'],
          'goals': (category['goals'] as List<Map<String, dynamic>>)
              .where((goal) => goal['duration'] == selectedTenure)
              .toList(),
        };
      }).where((category) => (category['goals'] as List).isNotEmpty).toList();
    }
    if (selectedInterestRate != null) {
      filteredFDs = filteredFDs.map((category) {
        return {
          'category': category['category'],
          'goals': (category['goals'] as List<Map<String, dynamic>>)
              .where((goal) => goal['expectedReturn'] == selectedInterestRate)
              .toList(),
        };
      }).where((category) => (category['goals'] as List).isNotEmpty).toList();
    }
    if (showTaxBenefitOnly) {
      filteredFDs = filteredFDs
          .where((category) => category['category'].contains('Tax-Saving'))
          .toList();
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'Goal-Based FD Plans'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters
            Wrap(
              spacing: 8.0,
              children: [
                // Filter by Goal Type
                DropdownButton<String>(
                  hint: const Text('Goal Type'),
                  value: selectedGoalType,
                  items: [
                    'Short-Term Goal FDs (1-3 years)',
                    'Medium-Term Goal FDs (3-7 years)',
                    'Long-Term Goal FDs (7+ years)',
                    'Tax-Saving FDs (5 years lock-in)',
                    'Recurring Deposit Based Goal FDs',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontFamily: 'OpenSans')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedGoalType = value;
                    });
                  },
                ),
                // Filter by Tenure
                DropdownButton<String>(
                  hint: const Text('Tenure'),
                  value: selectedTenure,
                  items: [
                    '1 year', '2 years', '3 years', '4 years', '5 years',
                    '6 years', '10 years', '12 years', '15 years', '20 years'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontFamily: 'OpenSans')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTenure = value;
                    });
                  },
                ),
                // Filter by Interest Rate
                DropdownButton<String>(
                  hint: const Text('Interest Rate'),
                  value: selectedInterestRate,
                  items: [
                    '7.0% p.a.', '7.2% p.a.', '7.5% p.a.', '7.8% p.a.',
                    '8.0% p.a.', '8.2% p.a.', '8.5% p.a.', '8.8% p.a.',
                    '9.0% p.a.', '9.2% p.a.'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontFamily: 'OpenSans')),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedInterestRate = value;
                    });
                  },
                ),
                // Filter by Tax Benefit
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tax Benefit', style: TextStyle(fontFamily: 'OpenSans')),
                    Checkbox(
                      value: showTaxBenefitOnly,
                      onChanged: (value) {
                        setState(() {
                          showTaxBenefitOnly = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grid View
            Column(
              children: filteredFDs.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category['category'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: (category['goals'] as List).length,
                      itemBuilder: (context, index) {
                        final goal = category['goals'][index];
                        IconData icon;
                        switch (goal['goalName']) {
                          case 'Emergency Fund':
                            icon = Icons.emergency;
                            break;
                          case 'Vacation Fund':
                          case 'Vacation Fund (RD)':
                            icon = Icons.card_travel;
                            break;
                          case 'Gadgets/Vehicle Purchase':
                            icon = Icons.devices;
                            break;
                          case 'Wedding Expenses':
                          case 'Big Family Event':
                            icon = Icons.celebration;
                            break;
                          case 'Higher Education Fund':
                          case 'Education Fund (RD)':
                          case 'Child Marriage/Studies':
                            icon = Icons.school;
                            break;
                          case 'Down Payment for House':
                            icon = Icons.home;
                            break;
                          case 'Business Startup Fund':
                            icon = Icons.business;
                            break;
                          case 'Retirement Fund':
                            icon = Icons.account_balance;
                            break;
                          case 'Wealth Creation':
                            icon = Icons.trending_up;
                            break;
                          case 'Legacy Planning':
                            icon = Icons.family_restroom;
                            break;
                          case 'Tax-Saving FD':
                            icon = Icons.account_balance_wallet;
                            break;
                          default:
                            icon = Icons.savings;
                        }
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => FDDetailsPage(goal: goal));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.orange, Color(0xFF2E7D32)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  icon,
                                  size: 28,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  goal['goalName'],
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '💸 ${goal['expectedReturn']} for ${goal['tenure']}',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '📅 Duration: ${goal['duration']}',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}