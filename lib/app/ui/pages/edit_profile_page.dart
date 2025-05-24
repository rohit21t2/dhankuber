import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import '../../controllers/profile_controller.dart';
import '../../controllers/auth_controller.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController nameController =
    TextEditingController(text: controller.name.value);
    final TextEditingController phoneController =
    TextEditingController(text: controller.phoneNumber.value.substring(3));
    final TextEditingController otpController = TextEditingController();
    final RxBool isPhoneEditing = false.obs;
    final RxBool isOTPRequested = false.obs;
    final RxString newPhoneNumber = ''.obs;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: Obx(() => Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update Profile',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.neutralLightGray,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: AppColors.primaryBrand), // Updated to orange
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryText),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryText),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primaryBrand), // Already orange
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        enabled: isPhoneEditing.value,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixText: '+91 ',
                          prefixStyle: const TextStyle(
                            color: AppColors.primaryText,
                            fontWeight: FontWeight.bold,
                          ),
                          labelStyle: const TextStyle(color: AppColors.primaryBrand), // Updated to orange
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryText),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryText),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryBrand), // Already orange
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (!isPhoneEditing.value)
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.primaryBrand),
                        onPressed: () {
                          isPhoneEditing.value = true;
                        },
                      ),
                  ],
                ),
                if (isPhoneEditing.value && !isOTPRequested.value) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        String newPhone = '+91${phoneController.text.trim()}';
                        if (newPhone == controller.phoneNumber.value) {
                          Get.snackbar('Info', 'Phone number is unchanged',
                              backgroundColor: AppColors.neutralLightGray,
                              colorText: AppColors.primaryText);
                          isPhoneEditing.value = false;
                          return;
                        }
                        newPhoneNumber.value = newPhone;
                        await authController.sendOTPForPhoneChange(newPhone);
                        isOTPRequested.value = true;
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Send OTP'),
                    ),
                  ),
                ],
                if (isOTPRequested.value) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: otpController,
                    decoration: InputDecoration(
                      labelText: 'Enter OTP',
                      labelStyle: const TextStyle(color: AppColors.primaryBrand), // Updated to orange
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryText),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryText),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primaryBrand), // Already orange
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        bool verified = await authController.verifyOTPForPhoneChange(otpController.text);
                        if (verified) {
                          await controller.updateProfile(nameController.text, newPhoneNumber.value);
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrand,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Verify OTP'),
                    ),
                  ),
                ],
                if (!isOTPRequested.value && !isPhoneEditing.value)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: ElevatedButton(
                        onPressed: () async {
                          await controller.updateProfile(nameController.text, controller.phoneNumber.value);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBrand,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (controller.isLoading.value || authController.isLoading.value)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBrand,
              ),
            ),
        ],
      )),
    );
  }
}