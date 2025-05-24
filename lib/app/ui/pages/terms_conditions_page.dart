import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Terms and Conditions'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Terms and Conditions\n\n[Insert full terms here or use a WebView to load from https://dhankuber.in/terms]',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'OpenSans',
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}