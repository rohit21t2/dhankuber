import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/colors.dart';
import '../components/custom_appbar.dart';
import '../widgets/custom_button.dart';
import 'forgot_mpin_page.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  _AppSettingsPageState createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isBiometricSupported = false;
  bool _isBiometricEnabled = false;
  bool _isMPINEnabled = false;
  bool _hasMPIN = false;
  bool _isLoading = false;
  List<String> _mpinDigits = List.filled(4, '');
  final List<TextEditingController> _mpinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _mpinFocusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadSettings();
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

  Future<void> _checkBiometricSupport() async {
    try {
      bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!mounted) return;
      setState(() {
        _isBiometricSupported = canCheckBiometrics && isDeviceSupported;
      });
      print('AppSettingsPage: Biometric support checked at 03:15 PM IST, May 24, 2025: $_isBiometricSupported');
    } catch (e) {
      print('AppSettingsPage: Error checking biometric support at 03:15 PM IST, May 24, 2025: $e');
    }
  }

  Future<void> _loadSettings() async {
    try {
      String? biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      String? mpinEnabled = await _secureStorage.read(key: 'mpin_enabled');
      String? mpin = await _secureStorage.read(key: 'mpin');
      if (!mounted) return;
      setState(() {
        _isBiometricEnabled = biometricEnabled == 'true';
        _isMPINEnabled = mpinEnabled == 'true';
        _hasMPIN = mpin != null && mpin.isNotEmpty;
      });
      print('AppSettingsPage: Settings loaded at 03:15 PM IST, May 24, 2025 - Biometric: $_isBiometricEnabled, MPIN: $_isMPINEnabled');
    } catch (e) {
      print('AppSettingsPage: Error loading settings at 03:15 PM IST, May 24, 2025: $e');
      Get.snackbar('Error', 'Failed to load settings: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    }
  }

  Future<void> _testBiometricAuth() async {
    try {
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        print('AppSettingsPage: No biometrics enrolled at 03:15 PM IST, May 24, 2025');
        Get.snackbar('Error', 'No biometrics enrolled. Please set up biometrics in your device settings.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        setState(() {
          _isBiometricEnabled = false;
        });
        return;
      }

      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Test biometric authentication for Dhankuber',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      if (authenticated) {
        print('AppSettingsPage: Biometric auth test successful at 03:15 PM IST, May 24, 2025');
        Get.snackbar('Success', 'Biometric authentication enabled successfully',
            backgroundColor: AppColors.successGreen, colorText: AppColors.background);
      } else {
        print('AppSettingsPage: Biometric auth test failed at 03:15 PM IST, May 24, 2025');
        Get.snackbar('Error', 'Biometric authentication failed',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        setState(() {
          _isBiometricEnabled = false;
        });
      }
    } catch (e) {
      print('AppSettingsPage: Error testing biometric auth at 03:15 PM IST, May 24, 2025: $e');
      String errorMessage = 'Failed to enable biometric authentication';
      if (e.toString().contains('NotEnrolled')) {
        errorMessage = 'No biometrics enrolled. Please set up biometrics in your device settings.';
      } else if (e.toString().contains('LockedOut')) {
        errorMessage = 'Too many attempts. Biometric authentication is temporarily locked out.';
      } else if (e.toString().contains('NotAvailable')) {
        errorMessage = 'Biometric authentication is not available on this device.';
      }
      Get.snackbar('Error', errorMessage,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      setState(() {
        _isBiometricEnabled = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (_isMPINEnabled && !_hasMPIN) {
        String mpin = _mpinDigits.join();
        if (mpin.length != 4) {
          Get.snackbar('Error', 'MPIN must be 4 digits',
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
          setState(() {
            _isLoading = false;
          });
          return;
        }
        await _secureStorage.write(key: 'mpin', value: mpin);
        if (!mounted) return;
        setState(() {
          _hasMPIN = true;
        });
      }

      // Save biometric setting
      await _secureStorage.write(key: 'biometric_enabled', value: _isBiometricEnabled.toString());
      await _secureStorage.write(key: 'mpin_enabled', value: _isMPINEnabled.toString());
      if (!_isMPINEnabled) {
        await _secureStorage.delete(key: 'mpin');
        if (!mounted) return;
        setState(() {
          _hasMPIN = false;
          _mpinDigits = List.filled(4, '');
          for (var controller in _mpinControllers) {
            controller.clear();
          }
        });
      }

      print('AppSettingsPage: Settings saved at 03:15 PM IST, May 24, 2025');
      Get.snackbar('Success', 'Settings saved successfully',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background);

      // Test biometric auth if enabled
      if (_isBiometricEnabled) {
        await _testBiometricAuth();
      }
    } catch (e) {
      print('AppSettingsPage: Error saving settings at 03:15 PM IST, May 24, 2025: $e');
      Get.snackbar('Error', 'Failed to save settings: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      setState(() {
        _isBiometricEnabled = false; // Reset biometric toggle on failure
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'App Settings'),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Settings',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enable Biometric Authentication',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'OpenSans',
                              color: AppColors.primaryText,
                            ),
                          ),
                          Switch(
                            value: _isBiometricEnabled,
                            onChanged: _isBiometricSupported
                                ? (value) {
                              setState(() {
                                _isBiometricEnabled = value;
                              });
                            }
                                : null,
                            activeColor: AppColors.primaryBrand,
                          ),
                        ],
                      ),
                      Text(
                        _isBiometricSupported
                            ? 'Use fingerprint or face recognition to access the app.'
                            : 'Biometric authentication is not supported on this device.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'OpenSans',
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Enable MPIN Security',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontFamily: 'OpenSans',
                              color: AppColors.primaryText,
                            ),
                          ),
                          Switch(
                            value: _isMPINEnabled,
                            onChanged: (value) {
                              setState(() {
                                _isMPINEnabled = value;
                                if (!value) {
                                  _mpinDigits = List.filled(4, '');
                                  for (var controller in _mpinControllers) {
                                    controller.clear();
                                  }
                                }
                              });
                            },
                            activeColor: AppColors.primaryBrand,
                          ),
                        ],
                      ),
                      if (_isMPINEnabled && !_hasMPIN)
                        Column(
                          children: [
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
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            _mpinDigits[index] = value;
                                          });
                                          if (index < 3) {
                                            _mpinFocusNodes[index + 1].requestFocus();
                                          } else {
                                            _mpinFocusNodes[index].unfocus();
                                          }
                                        } else {
                                          setState(() {
                                            _mpinDigits[index] = '';
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                      if (_isMPINEnabled && _hasMPIN)
                        CustomButton(
                          text: 'Change MPIN',
                          onPressed: () {
                            Get.to(() => const ForgotMPINPage());
                          },
                        ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Save Settings',
                        onPressed: _saveSettings,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBrand,
              ),
            ),
        ],
      ),
    );
  }
}