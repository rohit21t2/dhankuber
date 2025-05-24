import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';

class HelpCustomerServicePage extends StatelessWidget {
  const HelpCustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Help & Customer Service'),
      body: Center(
        child: Text(
          'Help & Customer Service Coming Soon',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontFamily: 'Poppins',
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}