import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';

class ReferralProgramPage extends StatelessWidget {
  const ReferralProgramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Referral Program'),
      body: Center(
        child: Text(
          'Referral Program Coming Soon',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'Poppins',
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}