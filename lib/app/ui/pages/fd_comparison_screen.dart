import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/comparison_controller.dart';
import '../../utils/colors.dart';

class FDComparisonScreen extends StatelessWidget {
  final List<FDPlan> selectedFDPlans;

  const FDComparisonScreen({super.key, required this.selectedFDPlans});

  @override
  Widget build(BuildContext context) {
    final ComparisonController comparisonController = Get.find<ComparisonController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Compare Fixed Deposits',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comparison Details',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            _buildComparisonTable(context),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  comparisonController.clearSelections();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Clear & Compare Again',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accentLightGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DataTable(
          columnSpacing: 16,
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.white, width: 1),
            verticalInside: BorderSide(color: Colors.white, width: 1),
            top: BorderSide(color: Colors.white, width: 1),
            bottom: BorderSide(color: Colors.white, width: 1),
            left: BorderSide(color: Colors.white, width: 1),
            right: BorderSide(color: Colors.white, width: 1),
          ),
          columns: [
            DataColumn(
              label: Text(
                'Details',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText, // Changed to black
                ),
              ),
            ),
            ...selectedFDPlans.map((plan) => DataColumn(
              label: Text(
                plan.bankName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )),
          ],
          rows: [
            DataRow(cells: [
              const DataCell(Text(
                'Interest Rate',
                style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              )),
              ...selectedFDPlans.map((plan) => DataCell(Text(
                '${plan.interestRate}%',
                style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              ))),
            ]),
            DataRow(cells: [
              const DataCell(Text(
                'Tenure',
                style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              )),
              ...selectedFDPlans.map((plan) => DataCell(Text(
                '${plan.tenureMonths} months',
                style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              ))),
            ]),
            DataRow(cells: [
              const DataCell(Text(
                'Issuer Type',
                style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              )),
              ...selectedFDPlans.map((plan) => DataCell(Text(
                plan.issuerType,
                style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              ))),
            ]),
            DataRow(cells: [
              const DataCell(Text(
                'Tax Saving',
                style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              )),
              ...selectedFDPlans.map((plan) => DataCell(Text(
                plan.isTaxSaving ? 'Yes' : 'No',
                style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
              ))),
            ]),
          ],
        ),
      ),
    );
  }
}