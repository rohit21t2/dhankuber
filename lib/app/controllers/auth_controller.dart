import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import '../utils/colors.dart';
import '../utils/validators.dart';
import '../ui/pages/login_page.dart';
import '../ui/pages/main_screen.dart';
import '../ui/pages/name_input_page.dart';
import '../ui/pages/otp_page.dart';
import '../ui/pages/security_check_page.dart';

class AuthController extends GetxController {
  final phoneNumber = ''.obs;
  final phoneInput = ''.obs;
  final otp = List<String>.filled(6, '').obs;
  final name = ''.obs;
  var verificationId = ''.obs;
  var canResendOTP = false.obs;
  var resendTimer = 30.obs;
  var isLoading = false.obs;
  var isOTPVerified = false.obs;
  var lastOTPSentTime = DateTime.now().subtract(const Duration(minutes: 1)).obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Utility function to format the current time
  String _getFormattedTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a \'IST\', MMMM dd, yyyy');
    return formatter.format(now);
  }

  @override
  void onInit() {
    super.onInit();
    if (kDebugMode) {
      print('AuthController initialized at ${_getFormattedTime()}');
    }
  }

  Future<bool> _hasPendingTransactions(String phoneNumber) async {
    try {
      QuerySnapshot transactions = await _firestore
          .collection('transactions')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('status', isEqualTo: 'pending')
          .get();
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
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }

      String? phone = _auth.currentUser!.phoneNumber;
      if (phone == null) {
        if (kDebugMode) {
          print('No phone number in auth at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'User data not found',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }

      bool hasPendingTransactions = await _hasPendingTransactions(phone);
      if (hasPendingTransactions) {
        if (kDebugMode) {
          print('Account deletion blocked: Pending transactions found at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Cannot delete account: Please clear all pending transactions',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting account: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to delete account: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Logging out user at ${_getFormattedTime()}...');
    }
    try {
      await _auth.signOut();
      await _secureStorage.deleteAll();
      if (kDebugMode) {
        print('User logged out, secure storage cleared at ${_getFormattedTime()}');
      }
      Get.offAllNamed('/login');
      Get.snackbar('Success', 'Logged out successfully',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } catch (e) {
      if (kDebugMode) {
        print('Error logging out: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to log out: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

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

  Future<void> sendOTP() async {
    if (isLoading.value) {
      if (kDebugMode) {
        print('sendOTP blocked: Already processing at ${_getFormattedTime()}');
      }
      return;
    }

    final now = DateTime.now();
    final timeSinceLastOTP = now.difference(lastOTPSentTime.value).inSeconds;
    if (timeSinceLastOTP < 1) { // Reduced cooldown to 1 second
      if (kDebugMode) {
        print('sendOTP blocked: Cooldown period, wait ${1 - timeSinceLastOTP}s at ${_getFormattedTime()}');
      }
      Get.snackbar('Please Wait', 'Please wait ${1 - timeSinceLastOTP}s before retrying',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      return;
    }

    isLoading.value = true;
    if (kDebugMode) {
      print('sendOTP called with phoneInput: ${phoneInput.value} at ${_getFormattedTime()}');
    }
    phoneNumber.value = '+91${phoneInput.value.trim()}';
    String? phoneError = Validators.validateIndianPhoneNumber(phoneNumber.value);
    if (phoneError != null) {
      if (kDebugMode) {
        print('Phone validation error: $phoneError at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', phoneError,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      isLoading.value = false;
      return;
    }

    try {
      lastOTPSentTime.value = now;
      // Navigate to OTPPage immediately to give the illusion of instant navigation
      Get.to(() => const OTPPage());
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber.value,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('Auto-verification completed at ${_getFormattedTime()}');
          }
          await _auth.signInWithCredential(credential);
          await _handleVerificationSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Verification failed: ${e.code} - ${e.message} at ${_getFormattedTime()}');
          }
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
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        },
        codeSent: (String vId, int? resendToken) {
          if (kDebugMode) {
            print('OTP sent, verificationId: $vId at ${_getFormattedTime()}');
          }
          verificationId.value = vId;
          startResendTimer();
          Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to ${phoneNumber.value}',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background);
        },
        codeAutoRetrievalTimeout: (String vId) {
          if (kDebugMode) {
            print('Auto-retrieval timeout, verificationId: $vId at ${_getFormattedTime()}');
          }
          verificationId.value = vId;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception in sendOTP: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      isLoading.value = false;
      return;
    }

    try {
      lastOTPSentTime.value = now;
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('Auto-verification completed for MPIN reset, ignoring at ${_getFormattedTime()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Verification failed: ${e.code} - ${e.message} at ${_getFormattedTime()}');
          }
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
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        },
        codeSent: (String vId, int? resendToken) {
          if (kDebugMode) {
            print('OTP sent for MPIN reset, verificationId: $vId at ${_getFormattedTime()}');
          }
          verificationId.value = vId;
          phoneNumber.value = phone;
          startResendTimer();
          Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to $phone',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background);
        },
        codeAutoRetrievalTimeout: (String vId) {
          if (kDebugMode) {
            print('Auto-retrieval timeout, verificationId: $vId at ${_getFormattedTime()}');
          }
          verificationId.value = vId;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception in sendOTPForMPINReset: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOTP() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('verifyOTP called at ${_getFormattedTime()}, OTP: ${otp.join()}, verificationId: ${verificationId.value}, UID: ${_auth.currentUser?.uid}, Phone: ${_auth.currentUser?.phoneNumber}');
    }
    String enteredOTP = otp.join();
    if (verificationId.value.isEmpty) {
      if (kDebugMode) {
        print('Verification ID is empty, redirecting to LoginPage at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Session expired. Please request a new OTP.',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      Get.offAllNamed('/login');
      isLoading.value = false;
      return;
    }
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: enteredOTP,
      );
      await _auth.signInWithCredential(credential);
      if (kDebugMode) {
        print('OTP verified successfully at ${_getFormattedTime()}');
      }
      await _handleVerificationSuccess();
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('OTP verification failed: ${e.code} - ${e.message} at ${_getFormattedTime()}');
      }
      String errorMessage;
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
      Get.snackbar('Error', errorMessage,
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in verifyOTP: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to verify OTP: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      Get.offAllNamed('/login');
      isLoading.value = false;
      return;
    }
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
          backgroundColor: AppColors.successGreen, colorText: AppColors.background);
    } catch (e) {
      if (kDebugMode) {
        print('OTP verification failed: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Invalid OTP',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _handleVerificationSuccess() async {
    isLoading.value = true;
    if (kDebugMode) {
      print('Handling verification success at ${_getFormattedTime()}, UID: ${_auth.currentUser?.uid}, Phone: ${_auth.currentUser?.phoneNumber}');
    }
    try {
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print('No authenticated user, redirecting to LoginPage at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Authentication failed. Please try again.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        await _secureStorage.deleteAll();
        Get.offAllNamed('/login');
        return;
      }

      String? phone = _auth.currentUser!.phoneNumber;
      if (phone == null) {
        if (kDebugMode) {
          print('No phone number in auth, redirecting to LoginPage at ${_getFormattedTime()}');
        }
        await _auth.signOut();
        await _secureStorage.deleteAll();
        Get.snackbar('Error', 'Authentication failed. Please try again.',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        Get.offAllNamed('/login');
        return;
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(phone)
          .get();
      if (kDebugMode) {
        print('Firestore query result: exists=${userDoc.exists}, data=${userDoc.data()} at ${_getFormattedTime()}');
      }

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
          await _firestore.collection('users').doc(phone).update({
            'deleteAfter': FieldValue.delete(),
          });
        } else if (deleteAfter != null) {
          if (kDebugMode) {
            print('Deletion period expired, creating new account at ${_getFormattedTime()}');
          }
          await _firestore.collection('users').doc(phone).delete();
          phoneNumber.value = phone;
          phoneInput.value = phoneNumber.value.substring(3);
          await _secureStorage.write(key: 'user_phone', value: phoneNumber.value);
          Get.snackbar('Success', 'OTP verified successfully!',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background);
          Get.to(() => const NameInputPage());
          return;
        }

        name.value = userDoc['name'] ?? '';
        phoneNumber.value = phone;
        phoneInput.value = phoneNumber.value.substring(3);
        await _secureStorage.write(key: 'user_name', value: name.value);
        await _secureStorage.write(key: 'user_phone', value: phoneNumber.value);
        if (kDebugMode) {
          print('User found: ${name.value} at ${_getFormattedTime()}');
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
      } else {
        if (kDebugMode) {
          print('No user data in Firestore for phone: $phone, redirecting to NameInputPage at ${_getFormattedTime()}');
        }
        phoneNumber.value = phone;
        phoneInput.value = phoneNumber.value.substring(3);
        await _secureStorage.write(key: 'user_phone', value: phoneNumber.value);
        Get.snackbar('Success', 'OTP verified successfully!',
            backgroundColor: AppColors.successGreen, colorText: AppColors.background);
        Get.to(() => const NameInputPage());
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error in _handleVerificationSuccess: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to process verification: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      await _auth.signOut();
      await _secureStorage.deleteAll();
      Get.offAllNamed('/login');
    } finally {
      isLoading.value = false;
    }
  }

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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      isLoading.value = false;
      return;
    }

    try {
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print('No authenticated user at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Authentication error, please log in again',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
      if (kDebugMode) {
        print('Exception in saveUserName: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to save user data: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
          backgroundColor: AppColors.successGreen, colorText: AppColors.background);
      Get.offNamed('/security');
    } catch (e) {
      if (kDebugMode) {
        print('Exception in saveNewMPIN: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to save MPIN: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      isLoading.value = false;
      return;
    }

    try {
      lastOTPSentTime.value = now;
      await _auth.verifyPhoneNumber(
        phoneNumber: newPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          if (kDebugMode) {
            print('Auto-verification completed for phone change, ignoring at ${_getFormattedTime()}');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (kDebugMode) {
            print('Verification failed: ${e.code} - ${e.message} at ${_getFormattedTime()}');
          }
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
              backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        },
        codeSent: (String vId, int? resendToken) {
          if (kDebugMode) {
            print('OTP sent for phone change, verificationId: $vId at ${_getFormattedTime()}');
          }
          verificationId.value = vId;
          phoneNumber.value = newPhone;
          startResendTimer();
          Get.snackbar('OTP Sent', 'A 6-digit OTP has been sent to $newPhone',
              backgroundColor: AppColors.successGreen, colorText: AppColors.background);
        },
        codeAutoRetrievalTimeout: (String vId) {
          if (kDebugMode) {
            print('Auto-retrieval timeout, verificationId: $vId at ${_getFormattedTime()}');
          }
          verificationId.value = vId;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Exception in sendOTPForPhoneChange: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }

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
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      Get.offAllNamed('/login');
      isLoading.value = false;
      return false;
    }
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
      if (kDebugMode) {
        print('OTP verification failed for phone change: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Invalid OTP',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}