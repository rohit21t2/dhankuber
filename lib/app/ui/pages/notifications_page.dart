import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/notification_controller.dart'; // Fixed import path
import '../../utils/colors.dart'; // Fixed import path
import '../components/custom_appbar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationController notificationController = Get.find<NotificationController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Notifications'),
      body: Obx(() => notificationController.notifications.isEmpty
          ? const Center(
        child: Text(
          'No notifications available.',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            color: AppColors.secondaryText,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notificationController.notifications.length,
        itemBuilder: (context, index) {
          final notification = notificationController.notifications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                notification.title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM dd, yyyy – hh:mm a')
                        .format(notification.timestamp),
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )),
    );
  }
}