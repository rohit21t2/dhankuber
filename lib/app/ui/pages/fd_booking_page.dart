import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';

class FDBookingPage extends StatelessWidget {
  final Map<String, dynamic> plan;

  const FDBookingPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    String selectedCategory = plan['category'];
    String selectedTenure = plan['tenure'];

    return Scaffold(
      appBar: CustomAppBar(title: 'Book ${plan['plan']}'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Your Fixed Deposit',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Bank: ${plan['bank']}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
            Text(
              'Plan: ${plan['plan']}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Category',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              items: ['Standard', 'Tax Saving', 'Senior Citizen']
                  .map((category) => DropdownMenuItem(
                value: category,
                child: Text(
                  category,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedCategory = value;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Select Tenure',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            DropdownButton<String>(
              value: selectedTenure,
              isExpanded: true,
              items: ['1 year', '2 years', '3 years', '4 years', '5 years']
                  .map((tenure) => DropdownMenuItem(
                value: tenure,
                child: Text(
                  tenure,
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
              ))
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedTenure = value;
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Success',
                  'FD booked successfully! (Dummy action)',
                  backgroundColor: AppColors.successGreen,
                  colorText: Colors.white,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
                shadowColor: Colors.black.withOpacity(0.1),
                elevation: 2,
              ),
              child: Text(
                'Confirm Booking',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}