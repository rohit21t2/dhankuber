import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import 'fd_booking_page.dart';

class FDDetailsPage extends StatelessWidget {
  final Map<String, dynamic> plan;

  const FDDetailsPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: plan['plan']),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan['bank'],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              plan['plan'],
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Interest Rate', plan['interestRate']),
            _buildDetailRow('Tenure', plan['tenure']),
            _buildDetailRow('Minimum Deposit', plan['minDeposit']),
            _buildDetailRow('Category', plan['category']),
            _buildDetailRow('Goal', plan['goal']),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Get.to(() => FDBookingPage(plan: plan)),
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
                'Book This FD',
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 16,
              color: AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}