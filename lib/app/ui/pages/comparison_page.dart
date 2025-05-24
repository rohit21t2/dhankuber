import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import 'fd_comparison_screen.dart';
import 'fd_calculator_screen.dart';
import 'help_customer_service_page.dart';

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

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  _ComparisonPageState createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  final List<FDPlan> allFDPlans = [
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
  ];

  List<FDPlan?> selectedFDPlans = [null, null, null]; // Allow 3 nullable selections

  List<FDPlan> getAvailableFDs(int fieldIndex) {
    // Exclude FDs selected in other fields
    List<FDPlan?> otherSelections = selectedFDPlans.asMap().entries
        .where((entry) => entry.key != fieldIndex)
        .map((entry) => entry.value)
        .toList();
    return allFDPlans
        .where((plan) => !otherSelections.contains(plan))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Comparison'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FD Comparison Card
            _buildCard(
              title: 'Compare Fixed Deposits',
              content: Column(
                children: [
                  Autocomplete<FDPlan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final availableFDs = getAvailableFDs(0);
                      if (textEditingValue.text.isEmpty) {
                        return availableFDs;
                      }
                      return availableFDs.where((plan) => plan.bankName
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (FDPlan plan) =>
                    '${plan.bankName} (${plan.interestRate}% | ${plan.tenureMonths} months)',
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Select FD 1',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.secondaryText),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.secondaryText),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryBrand),
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: AppColors.primaryBrand,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              selectedFDPlans[0] = null;
                            });
                          }
                        },
                      );
                    },
                    onSelected: (FDPlan plan) {
                      setState(() {
                        selectedFDPlans[0] = plan;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<FDPlan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final availableFDs = getAvailableFDs(1);
                      if (textEditingValue.text.isEmpty) {
                        return availableFDs;
                      }
                      return availableFDs.where((plan) => plan.bankName
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (FDPlan plan) =>
                    '${plan.bankName} (${plan.interestRate}% | ${plan.tenureMonths} months)',
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Select FD 2',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.secondaryText),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.secondaryText),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryBrand),
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: AppColors.primaryBrand,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              selectedFDPlans[1] = null;
                            });
                          }
                        },
                      );
                    },
                    onSelected: (FDPlan plan) {
                      setState(() {
                        selectedFDPlans[1] = plan;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<FDPlan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final availableFDs = getAvailableFDs(2);
                      if (textEditingValue.text.isEmpty) {
                        return availableFDs;
                      }
                      return availableFDs.where((plan) => plan.bankName
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    displayStringForOption: (FDPlan plan) =>
                    '${plan.bankName} (${plan.interestRate}% | ${plan.tenureMonths} months)',
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Select FD 3',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.secondaryText),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.secondaryText),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryBrand),
                          ),
                          floatingLabelStyle: const TextStyle(
                            color: AppColors.primaryBrand,
                            fontFamily: 'OpenSans',
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setState(() {
                              selectedFDPlans[2] = null;
                            });
                          }
                        },
                      );
                    },
                    onSelected: (FDPlan plan) {
                      setState(() {
                        selectedFDPlans[2] = plan;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Goal-Based Suggestion: ${selectedFDPlans.any((plan) => plan != null) ? selectedFDPlans.firstWhere((plan) => plan != null, orElse: () => allFDPlans[0])!.goal : 'Select FDs to see suggestions'}',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedFDPlans.where((plan) => plan != null).length >= 2
                        ? () => Get.to(() => FDComparisonScreen(
                      selectedFDPlans:
                      selectedFDPlans.where((plan) => plan != null).toList().cast<FDPlan>(),
                    ))
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Compare FDs',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // FD Calculator Card
            _buildCard(
              title: 'FD Calculator',
              content: Column(
                children: [
                  const Text(
                    'Calculate your FD returns with our easy-to-use calculator.',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const FDCalculatorScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Calculate Returns',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Personalized Investment Tips
            _buildCard(
              title: 'Personalized Investment Tips',
              content: Column(
                children: [
                  const Text(
                    'Get tailored FD investment advice through our customer support. Schedule a cold call to discuss your goals!',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.to(() => const HelpCustomerServicePage()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBrand,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Advice',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutralLightGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}