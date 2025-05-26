import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import 'dart:math';

class FDCalculatorScreen extends StatefulWidget {
  const FDCalculatorScreen({super.key});

  @override
  _FDCalculatorScreenState createState() => _FDCalculatorScreenState();
}

class _FDCalculatorScreenState extends State<FDCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _tenureController = TextEditingController();
  final _interestRateController = TextEditingController();
  String _compounding = 'Quarterly';
  double? _maturityAmount;
  double? _interestEarned;
  double? _principalAmount;

  void _calculateFD() {
    if (_formKey.currentState!.validate()) {
      final principal = double.parse(_principalController.text);
      final tenure = double.parse(_tenureController.text) / 12; // Convert months to years
      final interestRate = double.parse(_interestRateController.text) / 100;
      final compoundingPerYear = _compounding == 'Monthly'
          ? 12
          : _compounding == 'Quarterly'
          ? 4
          : 1;

      // Compound Interest Formula: A = P * (1 + r/n)^(n*t)
      final maturity = principal *
          pow(1 + interestRate / compoundingPerYear, compoundingPerYear * tenure);
      final interest = maturity - principal;

      setState(() {
        _principalAmount = principal;
        _maturityAmount = maturity;
        _interestEarned = interest;
      });
    }
  }

  @override
  void dispose() {
    _principalController.dispose();
    _tenureController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'FD Calculator'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _principalController,
                decoration: InputDecoration(
                  labelText: 'Principal Amount (₹)',
                  labelStyle: const TextStyle(
                    color: AppColors.primaryText, // Label color black
                    fontFamily: 'OpenSans',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: AppColors.primaryBrand, // Floating label orange
                    fontFamily: 'OpenSans',
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter principal amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tenureController,
                decoration: InputDecoration(
                  labelText: 'Tenure (Months)',
                  labelStyle: const TextStyle(
                    color: AppColors.primaryText, // Label color black
                    fontFamily: 'OpenSans',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: AppColors.primaryBrand, // Floating label orange
                    fontFamily: 'OpenSans',
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter tenure';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Enter a valid tenure';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestRateController,
                decoration: InputDecoration(
                  labelText: 'Interest Rate (% p.a.)',
                  labelStyle: const TextStyle(
                    color: AppColors.primaryText, // Label color black
                    fontFamily: 'OpenSans',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: AppColors.primaryBrand, // Floating label orange
                    fontFamily: 'OpenSans',
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter interest rate';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Enter a valid interest rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _compounding,
                decoration: InputDecoration(
                  labelText: 'Compounding Frequency',
                  labelStyle: const TextStyle(
                    color: AppColors.primaryText, // Label color black
                    fontFamily: 'OpenSans',
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryBrand), // Border orange
                  ),
                  floatingLabelStyle: const TextStyle(
                    color: AppColors.primaryBrand, // Floating label orange
                    fontFamily: 'OpenSans',
                  ),
                ),
                items: ['Monthly', 'Quarterly', 'Annually']
                    .map((value) => DropdownMenuItem(
                  value: value,
                  child: Text(value),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _compounding = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculateFD,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_maturityAmount != null && _interestEarned != null && _principalAmount != null)
                _buildResultsTable(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Calculation Results',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
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
                const DataColumn(
                  label: Text(
                    'Amount',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text(
                    'Principal Amount',
                    style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
                  )),
                  DataCell(Text(
                    '₹${_principalAmount!.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text(
                    'Interest Earned',
                    style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
                  )),
                  DataCell(Text(
                    '₹${_interestEarned!.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
                  )),
                ]),
                DataRow(cells: [
                  const DataCell(Text(
                    'Maturity Amount',
                    style: TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
                  )),
                  DataCell(Text(
                    '₹${_maturityAmount!.toStringAsFixed(2)}',
                    style: const TextStyle(fontFamily: 'OpenSans', color: AppColors.secondaryText),
                  )),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}