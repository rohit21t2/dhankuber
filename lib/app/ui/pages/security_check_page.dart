import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/colors.dart';
import '../widgets/custom_button.dart';
import 'main_screen.dart';
import 'login_page.dart';
import 'forgot_mpin_page.dart';

class SecurityCheckPage extends StatefulWidget {
  const SecurityCheckPage({super.key});

  @override
  _SecurityCheckPageState createState() => _SecurityCheckPageState();
}

class _SecurityCheckPageState extends State<SecurityCheckPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final AuthController _authController = Get.find<AuthController>();
  bool _isBiometricEnabled = false;
  bool _isMPINEnabled = false;
  String? _storedMPIN;
  bool _isLoading = true; // Start with loading state
  List<String> _mpinDigits = List.filled(4, '');
  final List<TextEditingController> _mpinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _mpinFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _checkSecuritySettings();
  }

  @override
  void dispose() {
    for (var controller in _mpinControllers) {
      controller.dispose();
    }
    for (var focusNode in _mpinFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _checkSecuritySettings() async {
    print('SecurityCheckPage: Checking security settings at 03:15 PM IST, May 24, 2025...');
    try {
      String? biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      String? mpinEnabled = await _secureStorage.read(key: 'mpin_enabled');
      String? mpin = await _secureStorage.read(key: 'mpin');
      if (!mounted) return;
      setState(() {
        _isBiometricEnabled = biometricEnabled == 'true';
        _isMPINEnabled = mpinEnabled == 'true';
        _storedMPIN = mpin;
        _isLoading = false; // Stop loading after settings are fetched
      });
      print('SecurityCheckPage: Biometric: $_isBiometricEnabled, MPIN: $_isMPINEnabled');
      if (!_isBiometricEnabled && !_isMPINEnabled) {
        print('SecurityCheckPage: No security enabled, redirecting to MainScreen...');
        Get.offAllNamed('/main');
      } else {
        print('SecurityCheckPage: Security enabled, attempting biometric auth...');
        _authenticate();
      }
    } catch (e) {
      print('SecurityCheckPage: Error checking security settings: $e');
      Get.snackbar('Error', 'Failed to load security settings: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      Get.offAllNamed('/main');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _authenticate() async {
    print('SecurityCheckPage: Attempting biometric authentication at 03:15 PM IST, May 24, 2025...');
    try {
      if (_isBiometricEnabled) {
        bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
        bool isDeviceSupported = await _localAuth.isDeviceSupported();
        if (!canCheckBiometrics || !isDeviceSupported) {
          print('SecurityCheckPage: Biometric auth not supported on this device');
          Get.snackbar('Error', 'Biometric authentication is not supported on this device',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
          return;
        }

        List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (availableBiometrics.isEmpty) {
          print('SecurityCheckPage: No biometrics enrolled');
          Get.snackbar('Error', 'No biometrics enrolled. Please set up biometrics in your device settings.',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
          return;
        }

        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access Dhankuber',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: true, // Let the system handle error dialogs
          ),
        );
        if (authenticated) {
          print('SecurityCheckPage: Biometric auth successful, redirecting to MainScreen...');
          Get.offAllNamed('/main');
          return;
        } else {
          print('SecurityCheckPage: Biometric auth failed');
          Get.snackbar('Error', 'Biometric authentication failed',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        }
      } else {
        print('SecurityCheckPage: No biometric auth, waiting for MPIN input');
      }
    } catch (e) {
      print('SecurityCheckPage: Authentication error: $e');
      String errorMessage = 'Authentication failed';
      if (e.toString().contains('NotEnrolled')) {
        errorMessage = 'No biometrics enrolled. Please set up biometrics in your device settings.';
      } else if (e.toString().contains('LockedOut')) {
        errorMessage = 'Too many attempts. Biometric authentication is temporarily locked out.';
      } else if (e.toString().contains('NotAvailable')) {
        errorMessage = 'Biometric authentication is not available on this device.';
      }
      Get.snackbar('Error', errorMessage,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    }
  }

  Future<void> _verifyMPIN() async {
    print('SecurityCheckPage: Verifying MPIN at 03:15 PM IST, May 24, 2025...');
    setState(() {
      _isLoading = true;
    });
    try {
      String enteredMPIN = _mpinDigits.join();
      if (enteredMPIN.length != 4) {
        print('SecurityCheckPage: Incomplete MPIN entered');
        Get.snackbar('Error', 'Please enter a 4-digit MPIN',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }
      if (enteredMPIN == _storedMPIN) {
        print('SecurityCheckPage: MPIN verified, redirecting to MainScreen...');
        Get.offAllNamed('/main');
      } else {
        print('SecurityCheckPage: Invalid MPIN');
        Get.snackbar('Error', 'Invalid MPIN',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        for (var controller in _mpinControllers) {
          controller.clear();
        }
        setState(() {
          _mpinDigits = List.filled(4, '');
        });
        _mpinFocusNodes[0].requestFocus();
      }
    } catch (e) {
      print('SecurityCheckPage: MPIN verification error: $e');
      Get.snackbar('Error', 'MPIN verification failed: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleMPINKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_mpinControllers[index].text.isEmpty && index > 0) {
        _mpinControllers[index - 1].clear();
        setState(() {
          _mpinDigits[index - 1] = '';
        });
        _mpinFocusNodes[index - 1].requestFocus();
      }
    }
  }

  void _onMPINChanged(String value, int index) {
    if (value.isNotEmpty) {
      setState(() {
        _mpinDigits[index] = value;
      });
      if (index < 3) {
        _mpinFocusNodes[index + 1].requestFocus();
      } else {
        _mpinFocusNodes[index].unfocus();
        if (_mpinDigits.every((digit) => digit.isNotEmpty)) {
          print('SecurityCheckPage: All 4 MPIN digits entered, auto-verifying...');
          _verifyMPIN();
        }
      }
    } else {
      setState(() {
        _mpinDigits[index] = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
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
                    'Authenticate to Continue',
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isBiometricEnabled
                        ? 'Use biometric or MPIN to access Dhankuber'
                        : 'Enter your MPIN to access Dhankuber',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isBiometricEnabled)
                    CustomButton(
                      text: 'Use Biometric',
                      onPressed: _authenticate,
                    ),
                  if (_isBiometricEnabled && _isMPINEnabled)
                    const SizedBox(height: 16),
                  if (_isMPINEnabled) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Enter MPIN',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
                                  borderSide: const BorderSide(color: AppColors.primaryBrand),
                                ),
                                counterText: '',
                              ),
                              maxLength: 1,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              onChanged: (value) => _onMPINChanged(value, index),
                            ),
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Get.to(() => const ForgotMPINPage());
                      },
                      child: const Text(
                        'Forgot MPIN?',
                        style: TextStyle(
                          color: AppColors.primaryBrand,
                          fontFamily: 'OpenSans',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Center(
              child: Lottie.asset(
                'assets/lottie/loading.json',
                width: 100,
                height: 100,
              ),
            ),
        ],
      ),
    );
  }
}