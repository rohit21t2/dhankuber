import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import '../../controllers/auth_controller.dart';
import '../../utils/colors.dart';
import '../widgets/custom_button.dart';
import '../components/custom_appbar.dart'; // Added for CustomAppBar
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
  bool _isInitialized = false; // Track initialization
  String? _storedMPIN;
  List<String> _mpinDigits = List.filled(4, '');
  final List<TextEditingController> _mpinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _mpinFocusNodes = List.generate(4, (_) => FocusNode());

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
    return formatter.format(now);
  }

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
    if (kDebugMode) {
      print('SecurityCheckPage: Checking security settings at ${_getFormattedTime()}...');
    }
    try {
      String? biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      String? mpinEnabled = await _secureStorage.read(key: 'mpin_enabled');
      String? mpin = await _secureStorage.read(key: 'mpin');
      if (!mounted) return;
      _isBiometricEnabled = biometricEnabled == 'true';
      _isMPINEnabled = mpinEnabled == 'true';
      _storedMPIN = mpin;
      _isInitialized = true; // Mark initialization as complete
      setState(() {}); // Update UI after initialization
      if (kDebugMode) {
        print('SecurityCheckPage: Biometric: $_isBiometricEnabled, MPIN: $_isMPINEnabled at ${_getFormattedTime()}');
      }
      if (!_isBiometricEnabled && !_isMPINEnabled) {
        if (kDebugMode) {
          print('SecurityCheckPage: No security enabled, redirecting to MainScreen at ${_getFormattedTime()}...');
        }
        Get.offAllNamed('/main');
      } else {
        if (kDebugMode) {
          print('SecurityCheckPage: Security enabled, attempting biometric auth at ${_getFormattedTime()}...');
        }
        _authenticate();
      }
    } catch (e) {
      if (kDebugMode) {
        print('SecurityCheckPage: Error checking security settings at ${_getFormattedTime()}: $e');
      }
      Get.snackbar('Error', 'Failed to load security settings: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      Get.offAllNamed('/main');
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _authenticate() async {
    if (kDebugMode) {
      print('SecurityCheckPage: Attempting biometric authentication at ${_getFormattedTime()}...');
    }
    try {
      if (_isBiometricEnabled) {
        bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
        bool isDeviceSupported = await _localAuth.isDeviceSupported();
        if (!canCheckBiometrics || !isDeviceSupported) {
          if (kDebugMode) {
            print('SecurityCheckPage: Biometric auth not supported on this device at ${_getFormattedTime()}');
          }
          Get.snackbar('Error', 'Biometric authentication is not supported on this device',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
          if (_isMPINEnabled) {
            if (kDebugMode) {
              print('SecurityCheckPage: Focusing MPIN input after biometric failure at ${_getFormattedTime()}');
            }
            _mpinFocusNodes[0].requestFocus();
          }
          return;
        }

        List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
        if (availableBiometrics.isEmpty) {
          if (kDebugMode) {
            print('SecurityCheckPage: No biometrics enrolled at ${_getFormattedTime()}');
          }
          Get.snackbar('Error', 'No biometrics enrolled. Please set up biometrics in your device settings.',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
          if (_isMPINEnabled) {
            if (kDebugMode) {
              print('SecurityCheckPage: Focusing MPIN input after biometric failure at ${_getFormattedTime()}');
            }
            _mpinFocusNodes[0].requestFocus();
          }
          return;
        }

        bool authenticated = await _localAuth.authenticate(
          localizedReason: 'Authenticate to access Dhankuber',
          options: const AuthenticationOptions(
            biometricOnly: true,
            stickyAuth: true,
            useErrorDialogs: false, // Handle errors manually for faster response
          ),
        );
        if (authenticated) {
          if (kDebugMode) {
            print('SecurityCheckPage: Biometric auth successful, redirecting to MainScreen at ${_getFormattedTime()}...');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.offAllNamed('/main');
          });
          return;
        } else {
          if (kDebugMode) {
            print('SecurityCheckPage: Biometric auth failed at ${_getFormattedTime()}');
          }
          Get.snackbar('Error', 'Biometric authentication failed',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
          if (_isMPINEnabled) {
            if (kDebugMode) {
              print('SecurityCheckPage: Focusing MPIN input after biometric failure at ${_getFormattedTime()}');
            }
            _mpinFocusNodes[0].requestFocus();
          }
        }
      } else {
        if (kDebugMode) {
          print('SecurityCheckPage: No biometric auth, waiting for MPIN input at ${_getFormattedTime()}');
        }
        if (_isMPINEnabled) {
          _mpinFocusNodes[0].requestFocus();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('SecurityCheckPage: Authentication error at ${_getFormattedTime()}: $e');
      }
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
      if (_isMPINEnabled) {
        if (kDebugMode) {
          print('SecurityCheckPage: Focusing MPIN input after biometric error at ${_getFormattedTime()}');
        }
        _mpinFocusNodes[0].requestFocus();
      }
    }
  }

  Future<void> _verifyMPIN() async {
    if (kDebugMode) {
      print('SecurityCheckPage: Verifying MPIN at ${_getFormattedTime()}...');
    }
    try {
      String enteredMPIN = _mpinDigits.join();
      if (enteredMPIN.length != 4) {
        if (kDebugMode) {
          print('SecurityCheckPage: Incomplete MPIN entered at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Please enter a 4-digit MPIN',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }
      if (enteredMPIN == _storedMPIN) {
        if (kDebugMode) {
          print('SecurityCheckPage: MPIN verified, redirecting to MainScreen at ${_getFormattedTime()}...');
        }
        Get.offAllNamed('/main');
      } else {
        if (kDebugMode) {
          print('SecurityCheckPage: Invalid MPIN at ${_getFormattedTime()}');
        }
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
      if (kDebugMode) {
        print('SecurityCheckPage: MPIN verification error at ${_getFormattedTime()}: $e');
      }
      Get.snackbar('Error', 'MPIN verification failed: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
          if (kDebugMode) {
            print('SecurityCheckPage: All 4 MPIN digits entered, auto-verifying at ${_getFormattedTime()}...');
          }
          _verifyMPIN();
        }
      }
    } else {
      setState(() {
        _mpinDigits[index] = '';
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_isMPINEnabled) {
      if (kDebugMode) {
        print('SecurityCheckPage: Back button pressed, focusing MPIN input at ${_getFormattedTime()}');
      }
      _mpinFocusNodes[0].requestFocus();
      return false; // Prevent back navigation, prompt for MPIN
    } else {
      if (kDebugMode) {
        print('SecurityCheckPage: Back button pressed, redirecting to LoginPage at ${_getFormattedTime()}');
      }
      Get.offAllNamed('/login');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: SizedBox.shrink(), // Show nothing until initialized
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Security'), // Added CustomAppBar
        body: SingleChildScrollView(
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
                    children: List.generate(
                      4,
                          (index) => Padding(
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
                      ),
                    ),
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
      ),
    );
  }
}