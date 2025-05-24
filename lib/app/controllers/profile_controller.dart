import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import '../utils/colors.dart';
import '../controllers/auth_controller.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var name = ''.obs;
  var phoneNumber = ''.obs;

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
      print('ProfileController initialized at ${_getFormattedTime()}');
    }
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      // Step 1: Load from secure storage first for instant display
      String? storedName = await _secureStorage.read(key: 'user_name');
      String? storedPhone = await _secureStorage.read(key: 'user_phone');
      if (storedName != null && storedPhone != null) {
        name.value = storedName;
        phoneNumber.value = storedPhone;
        if (kDebugMode) {
          print('Profile loaded from secure storage: name=${name.value}, phone=${phoneNumber.value} at ${_getFormattedTime()}');
        }
      }

      // Step 2: Fetch from Firestore in the background and update if needed
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print('No signed-in user at ${_getFormattedTime()}');
        }
        return;
      }

      String? phone = _auth.currentUser!.phoneNumber;
      if (phone == null) {
        if (kDebugMode) {
          print('No phone number in auth at ${_getFormattedTime()}');
        }
        return;
      }

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(phone)
          .get();

      if (userDoc.exists && userDoc['name'] != null) {
        String firestoreName = userDoc['name'];
        if (firestoreName != name.value || phone != phoneNumber.value) {
          name.value = firestoreName;
          phoneNumber.value = phone;
          // Update secure storage to keep it in sync
          await _secureStorage.write(key: 'user_name', value: firestoreName);
          await _secureStorage.write(key: 'user_phone', value: phone);
          if (kDebugMode) {
            print('Profile updated from Firestore: name=${name.value}, phone=${phoneNumber.value} at ${_getFormattedTime()}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching profile: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to load profile: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    }
  }

  Future<void> updateProfile(String newName, String newPhone) async {
    isLoading.value = true;
    try {
      if (_auth.currentUser == null) {
        if (kDebugMode) {
          print('No signed-in user at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Please log in to update profile',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }

      String? oldPhone = _auth.currentUser!.phoneNumber;
      if (oldPhone == null) {
        if (kDebugMode) {
          print('No phone number in auth at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Authentication error',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }

      if (newName.isEmpty) {
        if (kDebugMode) {
          print('Name is empty at ${_getFormattedTime()}');
        }
        Get.snackbar('Error', 'Please enter a valid name',
            backgroundColor: AppColors.errorRed, colorText: AppColors.background);
        return;
      }

      // If phone number has changed, update Firestore and secure storage
      if (newPhone != oldPhone) {
        if (kDebugMode) {
          print('Phone number changed from $oldPhone to $newPhone at ${_getFormattedTime()}');
        }
        // Move old user data to new phone document
        DocumentSnapshot oldUserDoc = await _firestore.collection('users').doc(oldPhone).get();
        if (oldUserDoc.exists) {
          Map<String, dynamic> userData = oldUserDoc.data() as Map<String, dynamic>;
          userData['phoneNumber'] = newPhone;
          userData['name'] = newName;
          userData['updatedAt'] = FieldValue.serverTimestamp();
          // Save to new phone document
          await _firestore.collection('users').doc(newPhone).set(userData);
          // Delete old phone document
          await _firestore.collection('users').doc(oldPhone).delete();
          if (kDebugMode) {
            print('User data migrated from $oldPhone to $newPhone at ${_getFormattedTime()}');
          }
        }
        // Update secure storage
        await _secureStorage.write(key: 'user_phone', value: newPhone);
      } else {
        // Only update the name in Firestore
        await _firestore.collection('users').doc(oldPhone).update({
          'name': newName,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (kDebugMode) {
          print('Name updated to $newName for phone $oldPhone at ${_getFormattedTime()}');
        }
      }

      // Update secure storage with new name
      await _secureStorage.write(key: 'user_name', value: newName);
      name.value = newName;
      phoneNumber.value = newPhone;
      Get.snackbar('Success', 'Profile updated successfully',
          backgroundColor: AppColors.successGreen, colorText: AppColors.background);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e at ${_getFormattedTime()}');
      }
      Get.snackbar('Error', 'Failed to update profile: $e',
          backgroundColor: AppColors.errorRed, colorText: AppColors.background);
    } finally {
      isLoading.value = false;
    }
  }
}