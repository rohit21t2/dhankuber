import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';

class UserAgreementsPage extends StatelessWidget {
  const UserAgreementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'User Agreements'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'User Agreements\n\n[Insert full agreements here or use a WebView to load from https://dhankuber.in/agreements]',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'OpenSans',
            color: AppColors.primaryText,
          ),
        ),
      ),
    );
  }
}