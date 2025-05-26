import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import 'fd_comparison_screen.dart';
import 'fd_calculator_screen.dart';
import 'help_customer_service_page.dart';
import '../controllers/comparison_controller.dart'; // Import the controller

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  _ComparisonPageState createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  late ComparisonController comparisonController;

  @override
  void initState() {
    super.initState();
    // Initialize the ComparisonController
    comparisonController = Get.put(ComparisonController());
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
              content: Obx(() => Column(
                children: [
                  Autocomplete<FDPlan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final availableFDs = comparisonController.getAvailableFDs(0);
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
                            comparisonController.clearSelection(0);
                          }
                        },
                      );
                    },
                    onSelected: (FDPlan plan) {
                      comparisonController.updateSelectedFD(0, plan);
                    },
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<FDPlan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final availableFDs = comparisonController.getAvailableFDs(1);
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
                            comparisonController.clearSelection(1);
                          }
                        },
                      );
                    },
                    onSelected: (FDPlan plan) {
                      comparisonController.updateSelectedFD(1, plan);
                    },
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<FDPlan>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      final availableFDs = comparisonController.getAvailableFDs(2);
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
                            comparisonController.clearSelection(2);
                          }
                        },
                      );
                    },
                    onSelected: (FDPlan plan) {
                      comparisonController.updateSelectedFD(2, plan);
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: comparisonController.selectedFDPlans
                        .where((plan) => plan != null)
                        .length >= 2
                        ? () => Get.to(() => FDComparisonScreen(
                      selectedFDPlans: comparisonController.selectedFDPlans
                          .where((plan) => plan != null)
                          .toList()
                          .cast<FDPlan>(),
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
              )),
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