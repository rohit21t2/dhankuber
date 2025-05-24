class Validators {
  static bool isValidIndianPhoneNumber(String phoneNumber) {
    final RegExp indianPhoneRegex = RegExp(r'^\+91[6-9][0-9]{9}$');
    return indianPhoneRegex.hasMatch(phoneNumber);
  }

  static String? validateIndianPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return 'Please enter your phone number';
    }
    if (!isValidIndianPhoneNumber(phoneNumber)) {
      return 'Please enter a valid Indian phone number (e.g., +919876543210)';
    }
    return null;
  }
}