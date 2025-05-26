import 'package:get/get.dart';

class Notification {
  final String title;
  final String message;
  final DateTime timestamp;

  Notification({
    required this.title,
    required this.message,
    required this.timestamp,
  });
}

class NotificationController extends GetxController {
  var notifications = <Notification>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Mock some notifications for now
    notifications.addAll([
      Notification(
        title: 'FD Maturity Reminder',
        message: 'Your FD with SBI is maturing in 5 days. Plan your next investment!',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Notification(
        title: 'New FD Plan Available',
        message: 'Check out the new high-interest FD plan from HDFC at 7.5% p.a.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Notification(
        title: 'App Update',
        message: 'A new version of Dhankuber is available. Update now for the latest features!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
    ]);
  }

  // Method to get the unread notification count
  int getUnreadCount() {
    // For now, assume all notifications are unread
    return notifications.length;
  }
}