import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/profile_controller.dart';
import 'edit_profile_page.dart';
import 'referral_program_page.dart';
import 'app_settings_page.dart';
import 'terms_conditions_page.dart';
import 'user_agreements_page.dart';
import 'help_customer_service_page.dart';
import 'about_page.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Profile'),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.neutralLightGray,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.name.value.isEmpty
                              ? 'User'
                              : controller.name.value,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.phoneNumber.value.isEmpty
                              ? '+91 XXX-XXX-XXXX'
                              : controller.phoneNumber.value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                            fontFamily: 'OpenSans',
                            fontSize: 16,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildOptionTile(
                context,
                icon: 'assets/icons/edit_profile.svg',
                title: 'Edit Profile',
                onTap: () => Get.to(() => const EditProfilePage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/referral.svg',
                title: 'Referral Program',
                onTap: () => Get.to(() => const ReferralProgramPage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/settings.svg',
                title: 'App Settings',
                onTap: () => Get.to(() => const AppSettingsPage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/terms.svg',
                title: 'Terms and Conditions',
                onTap: () => Get.to(() => const TermsConditionsPage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/agreement.svg',
                title: 'User Agreements',
                onTap: () => Get.to(() => const UserAgreementsPage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/help.svg',
                title: 'Help/Customer Service',
                onTap: () => Get.to(() => const HelpCustomerServicePage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/about.svg',
                title: 'About',
                onTap: () => Get.to(() => const AboutPage()),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/logout.svg',
                title: 'Logout',
                titleColor: AppColors.errorRed,
                onTap: () => _showLogoutDialog(context),
              ),
              _buildOptionTile(
                context,
                icon: 'assets/icons/delete.svg',
                title: 'Delete Account',
                titleColor: AppColors.errorRed,
                onTap: () => _showDeleteAccountDialog(context),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required String icon,
        required String title,
        Color? titleColor,
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.neutralLightGray,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        leading: SvgPicture.asset(
          icon,
          height: 24,
          color: titleColor ?? AppColors.primaryText,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            color: titleColor ?? AppColors.primaryText,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.secondaryText,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Log Out',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final authController = Get.find<AuthController>();
                await authController.logout();
                Get.back(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBrand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Account',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete your account? Your data will be scheduled for deletion in 30 days if no pending transactions remain. You can log in again within 30 days to restore your account.',
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: AppColors.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  color: AppColors.secondaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final authController = Get.find<AuthController>();
                await authController.deleteAccount();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}