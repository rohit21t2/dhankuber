import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:flutter/foundation.dart'; // Added for kDebugMode
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
  List<String> _mpinDigits = List.filled(4, '');
  final List<TextEditingController> _mpinControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _mpinFocusNodes = List.generate(4, (_) => FocusNode());
  String _selectedLanguage = 'English'; // Default language

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
    return formatter.format(now);
  }

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _loadSettings();
    _loadLanguage();
  }

  @override
  void dispose() {
    // If MPIN is not set, disable MPIN toggle before leaving the page
    if (_isMPINEnabled && !_hasMPIN) {
      if (kDebugMode) {
        print('AppSettingsPage: MPIN not set, reverting MPIN toggle to disabled at ${_getFormattedTime()}');
      }
      _isMPINEnabled = false;
      _saveSettings(); // Save the reverted state
    }

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
      if (kDebugMode) {
        print('AppSettingsPage: Biometric support checked at ${_getFormattedTime()}: $_isBiometricSupported');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error checking biometric support at ${_getFormattedTime()}: $e');
      }
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
      if (kDebugMode) {
        print('AppSettingsPage: Settings loaded at ${_getFormattedTime()} - Biometric: $_isBiometricEnabled, MPIN: $_isMPINEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error loading settings at ${_getFormattedTime()}: $e');
      }
      Get.snackbar('Error', 'Failed to load settings: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    }
  }

  Future<void> _loadLanguage() async {
    try {
      String? savedLanguage = await _secureStorage.read(key: 'app_language');
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        setState(() {
          _selectedLanguage = savedLanguage;
        });
      }
      if (kDebugMode) {
        print('AppSettingsPage: Language loaded at ${_getFormattedTime()}: $_selectedLanguage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error loading language at ${_getFormattedTime()}: $e');
      }
    }
  }

  Future<void> _saveLanguage(String language) async {
    try {
      await _secureStorage.write(key: 'app_language', value: language);
      if (kDebugMode) {
        print('AppSettingsPage: Language saved at ${_getFormattedTime()}: $language');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error saving language at ${_getFormattedTime()}: $e');
      }
    }
  }

  Future<void> _testBiometricAuth() async {
    try {
      List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        if (kDebugMode) {
          print('AppSettingsPage: No biometrics enrolled at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'No biometrics enrolled. Please set up biometrics in your device settings.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        setState(() {
          _isBiometricEnabled = false;
        });
        await _secureStorage.write(key: 'biometric_enabled', value: 'false');
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
        if (kDebugMode) {
          print('AppSettingsPage: Biometric auth test successful at ${_getFormattedTime()}');
        }
        Get.snackbar('Success', 'Biometric authentication enabled successfully',
            backgroundColor: AppColors.successGreen, colorText: AppColors.background);
      } else {
        if (kDebugMode) {
          print('AppSettingsPage: Biometric auth test failed at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Biometric authentication failed',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        setState(() {
          _isBiometricEnabled = false;
        });
        await _secureStorage.write(key: 'biometric_enabled', value: 'false');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error testing biometric auth at ${_getFormattedTime()}: $e');
      }
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
      await _secureStorage.write(key: 'biometric_enabled', value: 'false');
    }
  }

  Future<void> _saveSettings() async {
    try {
      // Only save _isMPINEnabled as true if an MPIN has been set
      if (_isMPINEnabled && !_hasMPIN) {
        if (kDebugMode) {
          print('AppSettingsPage: MPIN not set, reverting MPIN toggle to disabled during save at ${_getFormattedTime()}');
        }
        _isMPINEnabled = false;
      }

      // Save biometric and MPIN settings
      await _secureStorage.write(key: 'biometric_enabled', value: _isBiometricEnabled.toString());
      await _secureStorage.write(key: 'mpin_enabled', value: _isMPINEnabled.toString());
      if (!_isMPINEnabled) {
        await _secureStorage.delete(key: 'mpin');
        if (!mounted) return;
        setState(() {
          _hasMPIN = false;
          _isBiometricEnabled = false; // Disable biometric if MPIN is disabled
          _mpinDigits = List.filled(4, '');
          for (var controller in _mpinControllers) {
            controller.clear();
          }
        });
        await _secureStorage.write(key: 'biometric_enabled', value: 'false');
      }

      if (kDebugMode) {
        print('AppSettingsPage: Settings saved at ${_getFormattedTime()} - MPIN Enabled: $_isMPINEnabled, Biometric Enabled: $_isBiometricEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error saving settings at ${_getFormattedTime()}: $e');
      }
      Get.snackbar('Error', 'Failed to save settings: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      setState(() {
        _isBiometricEnabled = false; // Reset biometric toggle on failure
      });
      await _secureStorage.write(key: 'biometric_enabled', value: 'false');
    }
  }

  Future<void> _saveMPIN() async {
    try {
      String mpin = _mpinDigits.join();
      if (mpin.length != 4) {
        Get.snackbar('Error', 'MPIN must be 4 digits',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }
      await _secureStorage.write(key: 'mpin', value: mpin);
      if (!mounted) return;
      setState(() {
        _hasMPIN = true;
        _isMPINEnabled = true; // Enable MPIN toggle after successful MPIN creation
      });
      await _secureStorage.write(key: 'mpin_enabled', value: 'true'); // Save MPIN enabled state
      if (kDebugMode) {
        print('AppSettingsPage: MPIN saved and MPIN toggle enabled at ${_getFormattedTime()}');
      }
      Get.snackbar('Success', 'MPIN Successfully Created',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background);
    } catch (e) {
      if (kDebugMode) {
        print('AppSettingsPage: Error saving MPIN at ${_getFormattedTime()}: $e');
      }
      Get.snackbar('Error', 'Failed to save MPIN: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      setState(() {
        _isMPINEnabled = false; // Revert MPIN toggle on failure
      });
      await _secureStorage.write(key: 'mpin_enabled', value: 'false');
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
            print('AppSettingsPage: All 4 MPIN digits entered, auto-saving at ${_getFormattedTime()}...');
          }
          _saveMPIN();
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
      appBar: const CustomAppBar(title: 'App Settings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Settings Section
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
                        'Enable MPIN Security',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontFamily: 'OpenSans',
                          color: AppColors.primaryText,
                        ),
                      ),
                      Switch(
                        value: _isMPINEnabled,
                        onChanged: (value) async {
                          setState(() {
                            _isMPINEnabled = value;
                            if (!value) {
                              _mpinDigits = List.filled(4, '');
                              for (var controller in _mpinControllers) {
                                controller.clear();
                              }
                              _hasMPIN = false; // Reset MPIN state when toggled off
                            }
                          });
                          if (!value) {
                            await _saveSettings(); // Save immediately when toggling off
                          }
                          // Do not save settings when toggling on; wait until MPIN is set
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
                                  onChanged: (value) => _onMPINChanged(value, index),
                                ),
                              ),
                            ),
                          )),
                        ),
                      ],
                    ),
                  if (_isMPINEnabled && _hasMPIN)
                    ElevatedButton(
                      onPressed: () {
                        Get.to(() => const ForgotMPINPage());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Consistent button shape
                        ),
                      ),
                      child: Text(
                        'Change MPIN',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: Colors.black, // Consistent text color
                        ),
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
                        onChanged: _isBiometricSupported && _hasMPIN
                            ? (value) async {
                          setState(() {
                            _isBiometricEnabled = value;
                          });
                          await _saveSettings();
                          if (value) {
                            await _testBiometricAuth();
                          }
                        }
                            : (value) {
                          if (value && !_hasMPIN) {
                            Get.snackbar('Error', 'Please create an MPIN first to enable biometric authentication',
                                backgroundColor: AppColors.errorRed, colorText: AppColors.background);
                          }
                        },
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Language Settings Section
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
                    'Language Settings',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: InputDecoration(
                      labelText: 'Select Language',
                      labelStyle: const TextStyle(
                        fontFamily: 'OpenSans',
                        color: AppColors.secondaryText,
                      ),
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
                    ),
                    items: const [
                      DropdownMenuItem(value: 'English', child: Text('English')),
                      DropdownMenuItem(value: 'Hindi', child: Text('Hindi')),
                      DropdownMenuItem(value: 'Bengali', child: Text('Bengali')),
                      DropdownMenuItem(value: 'Marathi', child: Text('Marathi')),
                      DropdownMenuItem(value: 'Tamil', child: Text('Tamil')),
                      DropdownMenuItem(value: 'Telugu', child: Text('Telugu')),
                      DropdownMenuItem(value: 'Gujarati', child: Text('Gujarati')),
                      DropdownMenuItem(value: 'Kannada', child: Text('Kannada')),
                      DropdownMenuItem(value: 'Malayalam', child: Text('Malayalam')),
                      DropdownMenuItem(value: 'Punjabi', child: Text('Punjabi')),
                      DropdownMenuItem(value: 'Odia', child: Text('Odia')),
                      DropdownMenuItem(value: 'Urdu', child: Text('Urdu')),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                        Locale locale;
                        switch (newValue) {
                          case 'Hindi':
                            locale = const Locale('hi', 'IN');
                            break;
                          case 'Bengali':
                            locale = const Locale('bn', 'IN');
                            break;
                          case 'Marathi':
                            locale = const Locale('mr', 'IN');
                            break;
                          case 'Tamil':
                            locale = const Locale('ta', 'IN');
                            break;
                          case 'Telugu':
                            locale = const Locale('te', 'IN');
                            break;
                          case 'Gujarati':
                            locale = const Locale('gu', 'IN');
                            break;
                          case 'Kannada':
                            locale = const Locale('kn', 'IN');
                            break;
                          case 'Malayalam':
                            locale = const Locale('ml', 'IN');
                            break;
                          case 'Punjabi':
                            locale = const Locale('pa', 'IN');
                            break;
                          case 'Odia':
                            locale = const Locale('or', 'IN');
                            break;
                          case 'Urdu':
                            locale = const Locale('ur', 'IN');
                            break;
                          default:
                            locale = const Locale('en', 'US'); // English
                        }
                        Get.updateLocale(locale);
                        _saveLanguage(newValue);
                        Get.snackbar('language_changed'.tr, '${'language_set_to'.tr} $newValue',
                            backgroundColor: AppColors.successGreen, colorText: Colors.white);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}