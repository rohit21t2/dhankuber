import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import '../widgets/custom_button.dart';

class ForgotMPINPage extends StatefulWidget {
  const ForgotMPINPage({super.key});

  @override
  _ForgotMPINPageState createState() => _ForgotMPINPageState();
}

class _ForgotMPINPageState extends State<ForgotMPINPage> {
  final AuthController _controller = Get.find<AuthController>();
  final TextEditingController _phoneController = TextEditingController();
  bool _showOTPFields = false;
  List<String> mpinDigits = List.filled(4, '');
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _mpinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _mpinFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _loadPhoneNumber();
    _controller.isOTPVerified.listen((isVerified) {
      if (isVerified) {
        setState(() {
          mpinDigits = List.filled(4, '');
          for (var controller in _mpinControllers) {
            controller.clear();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    for (var controller in _mpinControllers) {
      controller.dispose();
    }
    for (var focusNode in _mpinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPhoneNumber() async {
    String? phone = await const FlutterSecureStorage().read(key: 'user_phone');
    if (phone != null && phone.isNotEmpty) {
      setState(() {
        _phoneController.text = phone.substring(3);
      });
    }
  }

  void _handleOTPKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_otpControllers[index].text.isEmpty && index > 0) {
        _otpControllers[index - 1].clear();
        _controller.otp[index - 1] = '';
        _otpFocusNodes[index - 1].requestFocus();
      }
    }
  }

  void _handleMPINKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_mpinControllers[index].text.isEmpty && index > 0) {
        _mpinControllers[index - 1].clear();
        mpinDigits[index - 1] = '';
        _mpinFocusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Reset MPIN'),
      body: Obx(() => Stack(
        children: [
          SingleChildScrollView(
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
                  'Reset Your MPIN',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _showOTPFields
                      ? _controller.isOTPVerified.value
                      ? 'Enter your new 4-digit MPIN'
                      : 'Enter the 6-digit OTP'
                      : 'Enter your phone number to receive OTP',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!_showOTPFields)
                  TextField(
                    controller: _phoneController,
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
                if (_showOTPFields && !_controller.isOTPVerified.value)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _handleOTPKeyEvent(event, index),
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
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
                                borderSide: const BorderSide(color: AppColors.primaryBrand), // Already orange
                              ),
                              counterText: '',
                            ),
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                _controller.otp[index] = value;
                                if (index < 5) {
                                  _otpFocusNodes[index + 1].requestFocus();
                                } else {
                                  _otpFocusNodes[index].unfocus();
                                }
                              } else {
                                _controller.otp[index] = '';
                              }
                            },
                          ),
                        ),
                      ),
                    )),
                  ),
                if (_showOTPFields && !_controller.isOTPVerified.value)
                  const SizedBox(height: 16),
                if (_showOTPFields && !_controller.isOTPVerified.value)
                  Text(
                    _controller.resendTimer.value > 0
                        ? 'Resend OTP in ${_controller.resendTimer.value}s'
                        : 'You can now resend OTP',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                if (_showOTPFields && !_controller.isOTPVerified.value)
                  TextButton(
                    onPressed: _controller.canResendOTP.value
                        ? () {
                      _controller.sendOTPForMPINReset('+91${_phoneController.text}');
                    }
                        : null,
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        color: _controller.canResendOTP.value
                            ? AppColors.primaryBrand
                            : AppColors.secondaryText,
                      ),
                    ),
                  ),
                if (_controller.isOTPVerified.value)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(4, (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _handleMPINKeyEvent(event, index),
                          child: TextField(
                            controller: _mpinControllers[index],
                            focusNode: _mpinFocusNodes[index],
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
                                borderSide: const BorderSide(color: AppColors.primaryBrand), // Already orange
                              ),
                              counterText: '',
                            ),
                            maxLength: 1,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() {
                                  mpinDigits[index] = value;
                                });
                                if (index < 3) {
                                  _mpinFocusNodes[index + 1].requestFocus();
                                } else {
                                  _mpinFocusNodes[index].unfocus();
                                }
                              } else {
                                setState(() {
                                  mpinDigits[index] = '';
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    )),
                  ),
                const SizedBox(height: 24),
                CustomButton(
                  text: _showOTPFields
                      ? (_controller.isOTPVerified.value ? 'Save New MPIN' : 'Verify OTP')
                      : 'Send OTP',
                  onPressed: () {
                    if (!_showOTPFields) {
                      _controller.sendOTPForMPINReset('+91${_phoneController.text}');
                      setState(() {
                        _showOTPFields = true;
                      });
                    } else if (!_controller.isOTPVerified.value) {
                      _controller.verifyOTPForMPINReset(_controller.otp.join());
                    } else {
                      String newMPIN = mpinDigits.join();
                      if (newMPIN.length == 4) {
                        _controller.saveNewMPIN(newMPIN);
                      } else {
                        Get.snackbar('Error', 'Please enter a 4-digit MPIN',
                            backgroundColor: AppColors.errorRed,
                            colorText: AppColors.background);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          if (_controller.isLoading.value)
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