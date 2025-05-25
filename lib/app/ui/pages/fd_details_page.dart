import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_booking_page.dart';

class FDDetailsPage extends StatelessWidget {
  final Map<String, dynamic> goal;

  const FDDetailsPage({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      appBar: CustomAppBar(title: '${goal['goalName']} Details'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Icon(
                  icon,
                  size: 50,
                  color: AppColors.primaryBrand,
                ),
              ),
              const SizedBox(height: 16),

              // Large Card for FD Details (same UI as All FDs)
              Container(
                width: double.infinity, // Full width for the card
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand,
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
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            goal['goalName'],
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Issuer: Suryoday Small Finance Bank',
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Expected Return: ${goal['expectedReturn']}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tenure: ${goal['tenure']}',
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      goal['taxSaving'] == true ? 'Tax Benefit: Yes' : 'Tax Benefit: No',
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Get.to(() => const FDBookingPage());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Proceed to Book FD',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}