import 'package:get/get.dart';

class Notification {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead; // Added to track read/unread status

  Notification({
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false, // Default to unread
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

  // Add fetchNotifications method
  Future<void> fetchNotifications() async {
    // Simulate fetching notifications (replace with actual data fetching logic, e.g., Firestore or API)
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate delay
    // For now, we already populated notifications in onInit, so no additional action is needed
    // In a real app, you might fetch from a server here and update notifications
  }

  // Method to get the unread notification count
  int getUnreadCount() {
    return notifications.where((notification) => !notification.isRead).length;
  }
}