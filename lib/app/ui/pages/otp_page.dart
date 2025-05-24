import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/custom_button.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import 'dart:async';

class OTPPage extends StatefulWidget {
  const OTPPage({super.key});

  @override
  _OTPPageState createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  final AuthController controller = Get.find<AuthController>();
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _countdown = 30;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    controller.canResendOTP.value = false;
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          controller.canResendOTP.value = true;
          timer.cancel();
        }
      });
    });
  }

  void _handleKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        controller.otp[index - 1] = '';
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  // Check if all OTP digits are filled
  bool _isOtpComplete() {
    return controller.otp.every((digit) => digit.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Verify OTP'),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We sent a 6-digit code to ${controller.phoneNumber.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _handleKeyEvent(event, index),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            decoration: InputDecoration(
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
                                borderSide: const BorderSide(color: AppColors.primaryBrand),
                              ),
                              counterText: '',
                            ),
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                controller.otp[index] = value;
                                if (index < 5) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  _focusNodes[index].unfocus();
                                  // Auto-process OTP when the 6th digit is entered
                                  if (_isOtpComplete()) {
                                    print('Auto-processing OTP at 09:57 PM IST, May 24, 2025');
                                    controller.verifyOTP();
                                  }
                                }
                              } else {
                                controller.otp[index] = '';
                              }
                            },
                          ),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _countdown > 0
                        ? 'Resend OTP in ${_countdown}s'
                        : 'You can now resend OTP',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: controller.canResendOTP.value
                        ? () {
                      print('Resend OTP clicked at 09:57 PM IST, May 24, 2025');
                      controller.sendOTP();
                      _startCountdown(); // Restart the countdown
                    }
                        : null,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: controller.canResendOTP.value
                            ? AppColors.primaryBrand
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Verify OTP',
                    onPressed: () {
                      print('Verify OTP clicked at 09:57 PM IST, May 24, 2025');
                      controller.verifyOTP();
                    },
                  ),
                ],
              ),
            ),
          ),
          if (controller.isLoading.value)
            Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 100,
                height: 100,
              ),
            ),
        ],
      )),
    );
  }
}