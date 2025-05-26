import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'About'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Dhankuber',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'OpenSans',
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'About Dhankuber',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dhankuber is a financial management app designed to help users plan and manage their fixed deposits, set financial goals, and track their portfolio with ease. Our mission is to empower users to achieve financial freedom through smart and secure investment options.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'OpenSans',
                  color: AppColors.secondaryText,
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),
              Text(
                'Developed by',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dhankuber Team',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'OpenSans',
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Contact Us',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For support or inquiries, reach out to us at support@dhankuber.com.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontFamily: 'OpenSans',
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}