import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Added for WhatsApp redirect
import 'package:intl/intl.dart'; // For formatting notification timestamps
import '../../controllers/home_controller.dart';
import '../../controllers/fd_plans_controller.dart'; // Added for FDPlansController
import '../../controllers/trending_plans_controller.dart'; // Re-added for TrendingPlansController
import '../../controllers/notification_controller.dart'; // Added for NotificationController
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'all_fd_plans_page.dart';
import 'goal_based_plans_page.dart';
import 'fd_trial_section_page.dart';
import 'fd_details_page.dart'; // Added for FDDetailsPage
import 'trending_plans_page.dart'; // Imports TrendingPlansPage
import 'notifications_page.dart'; // Added for NotificationsPage

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FDPlansController fdPlansController;
  late TrendingPlansController trendingPlansController;
  late NotificationController notificationController; // Added for notifications
  final String fdPlansControllerTag = 'HomePageFDPlansController'; // Unique tag for FDPlansController
  final String trendingControllerTag = 'HomePageTrendingPlansController'; // Unique tag for TrendingPlansController

  @override
  void initState() {
    super.initState();
    // Create tagged instances of controllers for HomePage
    fdPlansController = Get.put(FDPlansController(), tag: fdPlansControllerTag);
    trendingPlansController = Get.put(TrendingPlansController(), tag: trendingControllerTag);
    notificationController = Get.put(NotificationController()); // Initialize NotificationController
  }

  @override
  void dispose() {
    // Delete the tagged controller instances when the page is disposed
    Get.delete<FDPlansController>(tag: fdPlansControllerTag);
    Get.delete<TrendingPlansController>(tag: trendingControllerTag);
    super.dispose();
  }

  // Function to launch WhatsApp
  Future<void> _launchWhatsApp() async {
    final String phoneNumber = '+917506154578'; // Added country code explicitly
    final String message = 'Hello, I would like to get advice from experts.';
    // Use the whatsapp:// scheme to directly open WhatsApp
    final String whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}';
    final Uri whatsappUri = Uri.parse(whatsappUrl);

    try {
      // Debug: Check if we can launch the WhatsApp URL
      bool canLaunchWhatsapp = await canLaunchUrl(whatsappUri);
      print('Can launch WhatsApp URL ($whatsappUrl): $canLaunchWhatsapp');

      if (canLaunchWhatsapp) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
        print('WhatsApp launched successfully');
      } else {
        // Fallback to browser-based WhatsApp link
        final String fallbackUrl = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
        final Uri fallbackUri = Uri.parse(fallbackUrl);

        // Debug: Check if we can launch the fallback URL
        bool canLaunchFallback = await canLaunchUrl(fallbackUri);
        print('Can launch fallback URL ($fallbackUrl): $canLaunchFallback');

        if (canLaunchFallback) {
          await launchUrl(
            fallbackUri,
            mode: LaunchMode.externalApplication,
          );
          print('Fallback WhatsApp URL launched successfully');
        } else {
          Get.snackbar(
            'Error',
            'Could not open WhatsApp. Please ensure WhatsApp is installed and try again.',
            backgroundColor: AppColors.errorRed,
            colorText: Colors.white,
            duration: const Duration(seconds: 5),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
      Get.snackbar(
        'Error',
        'An error occurred while trying to launch WhatsApp: $e',
        backgroundColor: AppColors.errorRed,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Function to launch WebView for FD URLs
  Future<void> _launchFDWebView(BuildContext context, String url) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Suryoday Small Finance Bank',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: SizedBox(
          height: 300,
          child: WebViewWidget(
            controller: WebViewController()..loadRequest(Uri.parse(url)),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.neutralLightGray,
      ),
    );
  }

  // Function to show notifications dialog
  void _showNotificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: Obx(() => notificationController.notifications.isEmpty
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
            itemCount: notificationController.notifications.length > 3
                ? 3
                : notificationController.notifications.length, // Show up to 3 notifications
            itemBuilder: (context, index) {
              final notification = notificationController.notifications[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                title: Text(
                  notification.title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy – hh:mm a')
                          .format(notification.timestamp),
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 10,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const NotificationsPage());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View All',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppColors.neutralLightGray,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: '', // Removed the "Dhankuber" text
        leadingWidth: 180, // Increased width to prevent overflow
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 5.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8), // Space between logo and text
              Flexible(
                child: Text(
                  'Dhankuber',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18, // Reduced font size to prevent overflow
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        titleSpacing: 0,
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => const FDTrialSectionPage()),
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'FD',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Trial',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.support_agent,
              color: AppColors.primaryText,
              size: 28,
            ),
            tooltip: 'get_advice'.tr,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'get_advice'.tr,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  content: Text(
                    'connect_with_experts'.tr,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'cancel'.tr,
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _launchWhatsApp();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBrand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'connect'.tr,
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.neutralLightGray,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.language,
              color: AppColors.primaryText,
              size: 28,
            ),
            color: AppColors.primaryBrand,
            onSelected: (String language) {
              Locale locale;
              switch (language) {
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
                  locale = const Locale('en', 'US');
              }
              Get.updateLocale(locale);
              Get.snackbar('language_changed'.tr, '${'language_set_to'.tr} $language',
                  backgroundColor: AppColors.successGreen, colorText: Colors.white);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'English',
                child: Text('English', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Hindi',
                child: Text('Hindi', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Bengali',
                child: Text('Bengali', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Marathi',
                child: Text('Marathi', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Tamil',
                child: Text('Tamil', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Telugu',
                child: Text('Telugu', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Gujarati',
                child: Text('Gujarati', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Kannada',
                child: Text('Kannada', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Malayalam',
                child: Text('Malayalam', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Punjabi',
                child: Text('Punjabi', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Odia',
                child: Text('Odia', style: TextStyle(color: Colors.white)),
              ),
              const PopupMenuItem<String>(
                value: 'Urdu',
                child: Text('Urdu', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          Obx(() => Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications,
                  color: AppColors.primaryText,
                  size: 28,
                ),
                tooltip: 'Notifications',
                onPressed: () => _showNotificationsDialog(context),
              ),
              if (notificationController.getUnreadCount() > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notificationController.getUnreadCount().toString(),
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          )),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'featured_fds'.tr, // "Choose Best FD"
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: 'Poppins',
                color: AppColors.primaryText,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: homeController.fixerraFDs.length,
                itemBuilder: (context, index) {
                  final fd = homeController.fixerraFDs[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                              'Suryoday Small Finance Bank',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tenure: 12 Months',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 16,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Interest Rate (% p.a.): 9.10%',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 16,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Issuer Type: Bank',
                                  style: const TextStyle(
                                    fontFamily: 'OpenSans',
                                    fontSize: 16,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _launchFDWebView(context, fd['url']);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBrand,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Open FD',
                                      style: const TextStyle(
                                        fontFamily: 'OpenSans',
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: AppColors.neutralLightGray,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryBrand, width: 2),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/logo.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 70,
                            child: Text(
                              fd['title'],
                              style: const TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 12,
                                color: AppColors.primaryText,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Trending FDs (First Position)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'trending_fds'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.toNamed('/trending_plans'), // Use named route
                  child: Text(
                    'view_all'.tr,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: trendingPlansController.getTrendingFDsPreview(3).length, // Show 3 FDs as a preview
                itemBuilder: (context, index) {
                  final fd = trendingPlansController.getTrendingFDsPreview(3)[index];
                  return _buildFDCard(fd, () {
                    Get.to(() => FDDetailsPage(goal: {
                      'goalName': fd['bank'],
                      'expectedReturn': fd['interestRate'],
                      'tenure': fd['plan'],
                      'taxSaving': fd['taxSaving'],
                    }));
                  }, 'trending');
                },
              ),
            ),
            const SizedBox(height: 24),

            // All FDs (Second Position)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'all_fds'.tr,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                TextButton(
                  onPressed: () => Get.to(() => const AllFDPlansPage()),
                  child: Text(
                    'view_all'.tr,
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      color: AppColors.primaryBrand,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fdPlansController.getAllFDsPreview(3).length, // Show 3 FDs as a preview
                itemBuilder: (context, index) {
                  final fd = fdPlansController.getAllFDsPreview(3)[index];
                  return _buildFDCard(fd, () {
                    Get.to(() => FDDetailsPage(goal: {
                      'goalName': fd['bank'],
                      'expectedReturn': fd['interestRate'],
                      'tenure': fd['plan'],
                      'taxSaving': fd['taxSaving'],
                    }));
                  }, 'all');
                },
              ),
            ),
            const SizedBox(height: 24),

            // Goal-Based FDs (Third Position) - Single Card
            GestureDetector(
              onTap: () => Get.to(() => const GoalBasedPlansPage()),
              child: Container(
                width: double.infinity,
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32), // Solid dark green color
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '🎯 Plan Your Goals with Smart FDs',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => Get.to(() => const GoalBasedPlansPage()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBrand,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: Text(
                          'View All Goals'.tr,
                          style: const TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _buildFDCard(Map<String, dynamic> fd, VoidCallback onTap, String section) {
    Decoration backgroundDecoration;
    if (section == 'trending') {
      backgroundDecoration = BoxDecoration(
        color: AppColors.primaryBrand, // Orange color matching All FDs
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      );
    } else if (section == 'goalBased') {
      backgroundDecoration = BoxDecoration(
        color: const Color(0xFF2E7D32), // Solid dark green color
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      );
    } else {
      backgroundDecoration = BoxDecoration(
        color: AppColors.primaryBrand,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: backgroundDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fd['bank'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Tenure: ${fd['plan']}',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              'Interest Rate: ${fd['interestRate']}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Text(
              'Issuer: ${fd['issuerType']}',
              style: const TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}