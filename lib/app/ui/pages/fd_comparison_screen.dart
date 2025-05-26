import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import 'comparison_page.dart';

class FDComparisonScreen extends StatefulWidget {
  final List<FDPlan> selectedFDPlans;

  const FDComparisonScreen({super.key, required this.selectedFDPlans});

  @override
  _FDComparisonScreenState createState() => _FDComparisonScreenState();
}

class _FDComparisonScreenState extends State<FDComparisonScreen> {
  late List<FDPlan> displayedFDPlans;

  @override
  void initState() {
    super.initState();
    displayedFDPlans = List.from(widget.selectedFDPlans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Compare FDs'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Comparison Table
            Table(
              border: TableBorder.all(color: AppColors.secondaryText),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: AppColors.accentLightGreen),
                  children: [
                    const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Field',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ...displayedFDPlans.map((plan) => TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          plan.bankName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
                  ],
                ),
                _buildTableRow('Interest Rate', (plan) => '${plan.interestRate}%'),
                _buildTableRow('Tenure', (plan) => '${plan.tenureMonths} months'),
                _buildTableRow('Lock-in Period', (plan) => '${plan.lockInMonths} months'),
                _buildTableRow('Rating', (plan) => '${plan.rating}/5'),
                _buildTableRow('Min. Investment', (plan) => '₹${plan.minInvestment}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String field, String Function(FDPlan) getValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              field,
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        ...displayedFDPlans.map((plan) => TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              getValue(plan),
              style: const TextStyle(fontFamily: 'OpenSans'),
              textAlign: TextAlign.center,
            ),
          ),
        )),
      ],
    );
  }
}