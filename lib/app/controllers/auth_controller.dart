import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../utils/validators.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var phoneInput = ''.obs;
  var phoneNumber = ''.obs;
  var name = ''.obs;
  var canResendOTP = false.obs;
  var resendTimer = 30.obs;
  var isOTPVerified = false.obs;
  var lastOTPSentTime = DateTime.now().subtract(const Duration(minutes: 1)).obs;
  var otp = List.filled(6, '').obs;
  var verificationId = ''.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
    return formatter.format(now);
  }

  // Check if user is already logged in
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? phone = prefs.getString('phoneNumber');
    if (phone != null) {
      phoneNumber.value = phone;
      // Read name from secure storage
      String? storedName = await _secureStorage.read(key: 'user_name');
      if (storedName != null) {
        name.value = storedName;
      }
      isLoggedIn.value = true;
      if (kDebugMode) {
        print('User logged in from SharedPreferences: phone=$phone, name=${name.value} at ${_getFormattedTime()}');
      }
    }
  }

  // Check if OTP is complete
  bool _isOtpComplete() {
    return otp.every((digit) => digit.isNotEmpty);
  }

  // Start resend timer for OTP
  void startResendTimer() {
    canResendOTP.value = false;
    resendTimer.value = 30;
    Future.delayed(const Duration(seconds: 1), () {
      if (resendTimer.value > 0) {
        resendTimer.value--;
        startResendTimer();
      } else {
        canResendOTP.value = true;
      }
    });
  }

  // Check for pending transactions
  Future<bool> _hasPendingTransactions(String phoneNumber) async {
    try {
      QuerySnapshot transactions = await _firestore
          .collection('transactions')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'pending')
          .get(const GetOptions(source: Source.cache));
      bool hasPending = transactions.docs.isNotEmpty;
      if (kDebugMode) {
        print('Checked transactions for $phoneNumber: ${hasPending ? "Pending transactions found" : "No pending transactions"} at ${_getFormattedTime()}');
      }
      return hasPending;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking transactions: $e at ${_getFormattedTime()}');
      }
      return true;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Deleting account at ${_getFormattedTime()}...');
    }
    try {
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print('No signed-in user at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'No user logged in',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        return;
      }

      String? phone = _auth.currentUser!.phoneNumber;
      if (phone == null) {
        if (kDebugMode) {
          print('No phone number in auth at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'User data not found',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        return;
      }

      bool hasPendingTransactions = await _hasPendingTransactions(phone);
      if (hasPendingTransactions) {
        if (kDebugMode) {
          print('Account deletion blocked: Pending transactions found at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Cannot delete account: Please clear all pending transactions',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        return;
      }

      DateTime deleteAfter = DateTime.now().add(const Duration(days: 30));
      await _firestore.collection('users').doc(phone).update({
        'deleteAfter': Timestamp.fromDate(deleteAfter),
      });
      if (kDebugMode) {
        print('Account marked for deletion after: $deleteAfter at ${_getFormattedTime()}');
      }

      await _auth.signOut();
      await _secureStorage.deleteAll();
      Get.offAllNamed('/login');
      Get.snackbar('Warning', 'Account scheduled for deletion in 30 days',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to delete account: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP (for login)
  Future<void> sendOTP() async {
    if (phoneInput.value.length != 10) {
      Get.snackbar('Error', 'Please enter a valid 10-digit phone number',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      return;
    }

    final now = DateTime.now();
    final timeSinceLastOTP = now.difference(lastOTPSentTime.value).inSeconds;
    if (timeSinceLastOTP < 1) {
      if (kDebugMode) {
        print('sendOTP blocked: Cooldown period, wait ${1 - timeSinceLastOTP}s at ${_getFormattedTime()}');
      }
      Get.snackbar('Please Wait', 'Please wait ${1 - timeSinceLastOTP}s before retrying',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      return;
    }

    phoneNumber.value = '+91${phoneInput.value}';
    isLoading.value = true;

    // Ensure loading state lasts a maximum of 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (kDebugMode) {
          print('Loading timeout after 1 second at ${_getFormattedTime()}');
        }
      }
    });

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        isLoading.value = false;
        Get.snackbar('No Internet', 'Please check your internet connection.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        return;
      }

      lastOTPSentTime.value = now;
      Get.snackbar('Sending OTP', 'Please wait while we send an OTP to ${phoneNumber.value}',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
      Get.toNamed('/otp');

      if (kDebugMode) {
        print('Sending OTP to ${phoneNumber.value} at ${_getFormattedTime()}');
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          if (kDebugMode) {
            print('Auto-verification completed at ${_getFormattedTime()}');
          }
          await _handleSuccessfulLogin();
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many attempts. Please wait a few minutes and try again.';
              break;
            case 'quota-exceeded':
              errorMessage = 'OTP quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = e.message ?? 'Failed to send OTP';
          }
          Get.snackbar('Error', errorMessage,
              backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
          if (kDebugMode) {
            print('Verification failed: ${e.message} at ${_getFormattedTime()}');
          }
        },
        codeSent: (String verId, int? resendToken) {
          verificationId.value = verId;
          isLoading.value = false;
          startResendTimer();
          Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to ${phoneNumber.value}',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
          if (kDebugMode) {
            print('OTP sent successfully to ${phoneNumber.value} at ${_getFormattedTime()}');
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId.value = verId;
          isLoading.value = false;
          if (kDebugMode) {
            print('Code auto-retrieval timeout at ${_getFormattedTime()}');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Unexpected error in sendOTP: $e at ${_getFormattedTime()}');
      }
    }
  }

  // Verify OTP (for login)
  Future<void> verifyOTP() async {
    if (!_isOtpComplete()) {
      Get.snackbar('Error', 'Please enter the complete 6-digit OTP',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      return;
    }

    String enteredOtp = otp.join();
    isLoading.value = true;

    // Ensure loading state lasts a maximum of 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (kDebugMode) {
          print('Loading timeout after 1 second at ${_getFormattedTime()}');
        }
      }
    });

    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        Get.snackbar('No Internet', 'Please check your internet connection.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        isLoading.value = false;
        return;
      }

      if (kDebugMode) {
        print('Verifying OTP $enteredOtp for ${phoneNumber.value} at ${_getFormattedTime()}');
      }

      if (_auth.currentUser != null) {
        await _auth.currentUser!.reload();
        if (kDebugMode) {
          print('Firebase Auth session refreshed at ${_getFormattedTime()}');
        }
      }

      if (verificationId.value.isEmpty) {
        if (kDebugMode) {
          print('Verification ID is empty, redirecting to LoginPage at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Session expired. Please request a new OTP.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        Get.offAllNamed('/login');
        isLoading.value = false;
        return;
      }

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOtp,
      );

      await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('OTP verified successfully at ${_getFormattedTime()}');
      }

      await _handleSuccessfulLogin();
    } catch (e) {
      isLoading.value = false;
      String errorMessage = 'OTP verification failed: $e';
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'invalid-verification-code':
            errorMessage = 'Invalid OTP. Please try again.';
            break;
          case 'session-expired':
            errorMessage = 'Session expired. Please request a new OTP.';
            Get.offAllNamed('/login');
            break;
          default:
            errorMessage = e.message ?? 'Failed to verify OTP';
        }
      }
      Get.snackbar('Error', errorMessage,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Error verifying OTP: $e at ${_getFormattedTime()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Handle successful login
  Future<void> _handleSuccessfulLogin() async {
    try {
      bool userExists = await _checkUserExistsWithRetry(phoneNumber.value);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', phoneNumber.value);
      isLoggedIn.value = true;

      if (kDebugMode) {
        print('Controllers reinitialized after OTP verification at ${_getFormattedTime()}');
      }

      if (!userExists) {
        if (kDebugMode) {
          print('New user, navigating to NameInputPage at ${_getFormattedTime()}');
        }
        Get.offAllNamed('/name');
      } else {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(phoneNumber.value).get();
        name.value = userDoc['name'] ?? '';
        await _secureStorage.write(key: 'user_name', value: name.value);
        await _secureStorage.write(key: 'user_phone', value: phoneNumber.value);

        if (kDebugMode) {
          print('Returning user, checking security settings at ${_getFormattedTime()}');
        }

        String? biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
        String? mpinEnabled = await _secureStorage.read(key: 'mpin_enabled');
        bool isSecurityEnabled = biometricEnabled == 'true' || mpinEnabled == 'true';

        if (userDoc.exists) {
          Timestamp? deleteAfter;
          try {
            deleteAfter = userDoc.get('deleteAfter') as Timestamp?;
          } catch (e) {
            if (kDebugMode) {
              print('deleteAfter field does not exist: $e at ${_getFormattedTime()}');
            }
            deleteAfter = null;
          }
          if (kDebugMode) {
            print('deleteAfter: ${deleteAfter != null ? deleteAfter.toDate() : 'not set'} at ${_getFormattedTime()}');
          }
          if (deleteAfter != null && deleteAfter.toDate().isAfter(DateTime.now())) {
            if (kDebugMode) {
              print('Restoring account marked for deletion at ${_getFormattedTime()}');
            }
            await _firestore.collection('users').doc(phoneNumber.value).update({
              'deleteAfter': FieldValue.delete(),
            });
          } else if (deleteAfter != null) {
            if (kDebugMode) {
              print('Deletion period expired, creating new account at ${_getFormattedTime()}');
            }
            await _firestore.collection('users').doc(phoneNumber.value).delete();
            Get.offAllNamed('/name');
            return;
          }
        }

        Get.snackbar('Success', 'Login successful',
            backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));

        if (isSecurityEnabled) {
          if (kDebugMode) {
            print('Security enabled, navigating to SecurityCheckPage at ${_getFormattedTime()}');
          }
          Get.offAllNamed('/security');
        } else {
          if (kDebugMode) {
            print('No security enabled, navigating to MainScreen at ${_getFormattedTime()}');
          }
          Get.offAllNamed('/main');
        }
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Login failed: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Error in handleSuccessfulLogin: $e at ${_getFormattedTime()}');
      }
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user exists in Firestore with retry logic
  Future<bool> _checkUserExistsWithRetry(String phoneNumber) async {
    const int maxAttempts = 5;
    int attempt = 0;

    while (attempt < maxAttempts) {
      try {
        attempt++;
        if (kDebugMode) {
          print('Attempt $attempt to fetch user doc for $phoneNumber at ${_getFormattedTime()}');
        }

        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(phoneNumber)
            .get();

        return userDoc.exists;
      } catch (e) {
        if (e.toString().contains('cloud_firestore/unavailable') && attempt < maxAttempts) {
          int baseDelay = 1000;
          int delay = baseDelay * (pow(2, attempt) as int) + Random().nextInt(1000);
          if (kDebugMode) {
            print('Retrying after $delay ms due to error: $e at ${_getFormattedTime()}');
          }
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        } else {
          if (kDebugMode) {
            print('Unexpected error in checkUserExists: $e at ${_getFormattedTime()}');
          }
          rethrow;
        }
      }
    }

    throw Exception('Service unavailable after $maxAttempts attempts');
  }

  // Logout method
  Future<void> logout() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Logging out user at ${_getFormattedTime()}...');
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('phoneNumber');
      await _auth.signOut();
      await _secureStorage.deleteAll();
      isLoggedIn.value = false;
      phoneInput.value = '';
      phoneNumber.value = '';
      name.value = '';
      verificationId.value = '';
      otp.value = List.filled(6, '');
      isLoading.value = false; // Reset loading state before navigation
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('User logged out at ${_getFormattedTime()}');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to log out: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Error logging out: $e at ${_getFormattedTime()}');
      }
    }
  }

  // Send OTP for MPIN reset
  Future<void> sendOTPForMPINReset(String phone) async {
    if (isLoading.value) {
      if (kDebugMode) {
        print('sendOTPForMPINReset blocked: Already processing at ${_getFormattedTime()}');
      }
      return;
    }

    final now = DateTime.now();
    final timeSinceLastOTP = now.difference(lastOTPSentTime.value).inSeconds;
    if (timeSinceLastOTP < 1) {
      if (kDebugMode) {
        print('sendOTPForMPINReset blocked: Cooldown period, wait ${1 - timeSinceLastOTP}s at ${_getFormattedTime()}');
      }
      Get.snackbar('Please Wait', 'Please wait ${1 - timeSinceLastOTP}s before retrying',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      return;
    }

    isLoading.value = true;
    if (kDebugMode) {
      print('sendOTPForMPINReset called with phone: $phone at ${_getFormattedTime()}');
    }
    String? phoneError = Validators.validateIndianPhoneNumber(phone);
    if (phoneError != null) {
      if (kDebugMode) {
        print('Phone validation error: $phoneError at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', phoneError,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      isLoading.value = false;
      return;
    }

    // Ensure loading state lasts a maximum of 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (kDebugMode) {
          print('Loading timeout after 1 second at ${_getFormattedTime()}');
        }
      }
    });

    try {
      lastOTPSentTime.value = now;
      Get.snackbar('Sending OTP', 'Please wait while we send an OTP to $phone',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('Auto-verification completed for MPIN reset, ignoring at ${_getFormattedTime()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many attempts. Please wait a few minutes and try again.';
              break;
            case 'quota-exceeded':
              errorMessage = 'OTP quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = e.message ?? 'Failed to send OTP';
          }
          Get.snackbar('Error', errorMessage,
              backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
          if (kDebugMode) {
            print('Verification failed: ${e.message} at ${_getFormattedTime()}');
          }
        },
        codeSent: (String vId, int? resendToken) {
          verificationId.value = vId;
          phoneNumber.value = phone;
          isLoading.value = false;
          startResendTimer();
          Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to $phone',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
          if (kDebugMode) {
            print('OTP sent for MPIN reset, verificationId: $vId at ${_getFormattedTime()}');
          }
        },
        codeAutoRetrievalTimeout: (String vId) {
          verificationId.value = vId;
          isLoading.value = false;
          if (kDebugMode) {
            print('Auto-retrieval timeout, verificationId: $vId at ${_getFormattedTime()}');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Exception in sendOTPForMPINReset: $e at ${_getFormattedTime()}');
      }
    }
  }

  // Verify OTP for MPIN reset
  Future<void> verifyOTPForMPINReset(String enteredOTP) async {
    isLoading.value = true;
    if (kDebugMode) {
      print('verifyOTPForMPINReset called at ${_getFormattedTime()}, OTP: $enteredOTP');
    }
    if (verificationId.value.isEmpty) {
      if (kDebugMode) {
        print('Verification ID is empty, redirecting to LoginPage at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Session expired. Please request a new OTP.',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      Get.offAllNamed('/login');
      isLoading.value = false;
      return;
    }

    // Ensure loading state lasts a maximum of 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (kDebugMode) {
          print('Loading timeout after 1 second at ${_getFormattedTime()}');
        }
      }
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOTP,
      );
      await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('OTP verified successfully for MPIN reset at ${_getFormattedTime()}');
      }
      isOTPVerified.value = true;
      Get.snackbar('Success', 'OTP verified successfully',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('OTP verification failed: $e at ${_getFormattedTime()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP for phone number change
  Future<void> sendOTPForPhoneChange(String newPhone) async {
    if (isLoading.value) {
      if (kDebugMode) {
        print('sendOTPForPhoneChange blocked: Already processing at ${_getFormattedTime()}');
      }
      return;
    }

    final now = DateTime.now();
    final timeSinceLastOTP = now.difference(lastOTPSentTime.value).inSeconds;
    if (timeSinceLastOTP < 1) {
      if (kDebugMode) {
        print('sendOTPForPhoneChange blocked: Cooldown period, wait ${1 - timeSinceLastOTP}s at ${_getFormattedTime()}');
      }
      Get.snackbar('Please Wait', 'Please wait ${1 - timeSinceLastOTP}s before retrying',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      return;
    }

    isLoading.value = true;
    if (kDebugMode) {
      print('sendOTPForPhoneChange called with newPhone: $newPhone at ${_getFormattedTime()}');
    }
    String? phoneError = Validators.validateIndianPhoneNumber(newPhone);
    if (phoneError != null) {
      if (kDebugMode) {
        print('Phone validation error: $phoneError at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', phoneError,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      isLoading.value = false;
      return;
    }

    // Ensure loading state lasts a maximum of 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (kDebugMode) {
          print('Loading timeout after 1 second at ${_getFormattedTime()}');
        }
      }
    });

    try {
      lastOTPSentTime.value = now;
      Get.snackbar('Sending OTP', 'Please wait while we send an OTP to $newPhone',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
      await _auth.verifyPhoneNumber(
        phoneNumber: newPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('Auto-verification completed for phone change, ignoring at ${_getFormattedTime()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          String errorMessage;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'Invalid phone number format';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many attempts. Please wait a few minutes and try again.';
              break;
            case 'quota-exceeded':
              errorMessage = 'OTP quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = e.message ?? 'Failed to send OTP';
          }
          Get.snackbar('Error', errorMessage,
              backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
          if (kDebugMode) {
            print('Verification failed: ${e.message} at ${_getFormattedTime()}');
          }
        },
        codeSent: (String vId, int? resendToken) {
          verificationId.value = vId;
          phoneNumber.value = newPhone;
          isLoading.value = false;
          startResendTimer();
          Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to $newPhone',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
          if (kDebugMode) {
            print('OTP sent for phone change, verificationId: $vId at ${_getFormattedTime()}');
          }
        },
        codeAutoRetrievalTimeout: (String vId) {
          verificationId.value = vId;
          isLoading.value = false;
          if (kDebugMode) {
            print('Auto-retrieval timeout, verificationId: $vId at ${_getFormattedTime()}');
          }
        },
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Exception in sendOTPForPhoneChange: $e at ${_getFormattedTime()}');
      }
    }
  }

  // Verify OTP for phone number change
  Future<bool> verifyOTPForPhoneChange(String enteredOTP) async {
    isLoading.value = true;
    if (kDebugMode) {
      print('verifyOTPForPhoneChange called at ${_getFormattedTime()}, OTP: $enteredOTP');
    }
    if (verificationId.value.isEmpty) {
      if (kDebugMode) {
        print('Verification ID is empty, redirecting to LoginPage at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Session expired. Please request a new OTP.',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      Get.offAllNamed('/login');
      isLoading.value = false;
      return false;
    }

    // Ensure loading state lasts a maximum of 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (isLoading.value) {
        isLoading.value = false;
        if (kDebugMode) {
          print('Loading timeout after 1 second at ${_getFormattedTime()}');
        }
      }
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOTP,
      );
      await _auth.currentUser!.updatePhoneNumber(credential);
      if (kDebugMode) {
        print('Phone number updated successfully in Firebase Auth at ${_getFormattedTime()}');
      }
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('OTP verification failed for phone change: $e at ${_getFormattedTime()}');
      }
      return false;
    }
  }

  // Save user name
  Future<void> saveUserName(String userName) async {
    isLoading.value = true;
    if (kDebugMode) {
      print('saveUserName called with name: $userName at ${_getFormattedTime()}');
    }
    if (userName.isEmpty) {
      if (kDebugMode) {
        print('Name is empty at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Please enter your name',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      isLoading.value = false;
      return;
    }

    try {
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print('No authenticated user at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Authentication error, please log in again',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        await _secureStorage.deleteAll();
        Get.offAllNamed('/login');
        return;
      }

      String? phone = _auth.currentUser!.phoneNumber;
      if (phone == null) {
        if (kDebugMode) {
          print('No phone number in auth at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Authentication error, please log in again',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
        await _auth.signOut();
        await _secureStorage.deleteAll();
        Get.offAllNamed('/login');
        return;
      }

      if (kDebugMode) {
        print('Saving user data to Firestore for phone: $phone at ${_getFormattedTime()}');
      }
      await _firestore.collection('users').doc(phone).set({
        'phoneNumber': phone,
        'name': userName,
        'createdAt': FieldValue.serverTimestamp(),
        'referralCode': '',
      });
      name.value = userName;
      await _secureStorage.write(key: 'user_name', value: userName);
      await _secureStorage.write(key: 'user_phone', value: phone);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('phoneNumber', phone);
      isLoggedIn.value = true;

      if (kDebugMode) {
        print('User data saved, navigating to MainScreen or SecurityCheckPage at ${_getFormattedTime()}');
      }

      String? biometricEnabled = await _secureStorage.read(key: 'biometric_enabled');
      String? mpinEnabled = await _secureStorage.read(key: 'mpin_enabled');
      bool isSecurityEnabled = biometricEnabled == 'true' || mpinEnabled == 'true';
      if (isSecurityEnabled) {
        if (kDebugMode) {
          print('Security enabled, redirecting to SecurityCheckPage at ${_getFormattedTime()}');
        }
        Get.offAllNamed('/security');
      } else {
        if (kDebugMode) {
          print('No security enabled, redirecting to MainScreen at ${_getFormattedTime()}');
        }
        Get.offAllNamed('/main');
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save user data: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Exception in saveUserName: $e at ${_getFormattedTime()}');
      }
    }
  }

  // Save new MPIN
  Future<void> saveNewMPIN(String newMPIN) async {
    isLoading.value = true;
    if (kDebugMode) {
      print('saveNewMPIN called with MPIN: $newMPIN at ${_getFormattedTime()}');
    }
    if (newMPIN.length != 4) {
      if (kDebugMode) {
        print('Invalid MPIN length at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'MPIN must be 4 digits',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      isLoading.value = false;
      return;
    }

    try {
      await _secureStorage.write(key: 'mpin', value: newMPIN);
      await _secureStorage.write(key: 'mpin_enabled', value: 'true');
      isOTPVerified.value = false;
      if (kDebugMode) {
        print('New MPIN saved at ${_getFormattedTime()}');
      }
      Get.snackbar('Success', 'MPIN updated successfully',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background, duration: const Duration(seconds: 2));
      Get.offNamed('/security');
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save MPIN: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background, duration: const Duration(seconds: 2));
      if (kDebugMode) {
        print('Exception in saveNewMPIN: $e at ${_getFormattedTime()}');
      }
    }
  }
}