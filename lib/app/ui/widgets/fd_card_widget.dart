import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class FDCardWidget extends StatelessWidget {
  final Map<String, dynamic> plan;
  final VoidCallback onTap;
  final bool isFeatured;
  final bool isTrending;

  const FDCardWidget({
    super.key,
    required this.plan,
    required this.onTap,
    this.isFeatured = false,
    this.isTrending = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTrending ? const Color(0xFFFFF3E0).withOpacity(0.5) : AppColors.neutralLightGray,
          borderRadius: BorderRadius.circular(16),
          border: isFeatured ? Border.all(color: AppColors.primaryBrand, width: 1) : null,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['bank'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentLightGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    plan['category'],
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.secondaryBrand,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan['plan'],
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Interest Rate',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      plan['interestRate'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tenure',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    Text(
                      plan['tenure'],
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Min. Deposit: ${plan['minDeposit']}',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Goal: ${plan['goal']}',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.successGreen,
                    ),
                  ),
                ),
                if (plan['isTrending'] || isTrending)
                  const SizedBox(width: 8),
                if (plan['isTrending'] || isTrending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBrand.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Trending',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}