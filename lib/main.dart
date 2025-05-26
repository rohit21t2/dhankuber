import 'dart:io' show Platform; // For platform checks
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Added for kDebugMode
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Fixed import
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import 'package:webview_flutter/webview_flutter.dart'; // Import for WebView platform setup
import 'package:webview_flutter_android/webview_flutter_android.dart'; // Android-specific WebView
import 'app/controllers/auth_controller.dart';
import 'app/controllers/home_controller.dart';
import 'app/controllers/fd_plans_controller.dart';
import 'app/controllers/portfolio_controller.dart';
import 'app/controllers/payments_controller.dart';
import 'app/controllers/profile_controller.dart';
import 'app/controllers/goal_based_plans_controller.dart';
import 'app/controllers/comparison_controller.dart'; // Keep for HomePage usage
import 'app/controllers/notification_controller.dart'; // Added import for NotificationController
import 'app/ui/pages/login_page.dart';
import 'app/ui/pages/otp_page.dart';
import 'app/ui/pages/name_input_page.dart';
import 'app/ui/pages/main_screen.dart';
import 'app/ui/pages/security_check_page.dart';
import 'app/ui/pages/home_page.dart';
import 'app/ui/pages/all_fd_plans_page.dart';
import 'app/ui/pages/trending_plans_page.dart';
import 'app/ui/pages/goal_based_plans_page.dart';
import 'app/ui/pages/fd_trial_section_page.dart';
import 'app/ui/pages/fd_booking_page.dart';
import 'app/ui/pages/fd_comparison_screen.dart';
import 'app/ui/pages/fd_calculator_screen.dart';
import 'app/ui/pages/portfolio_page.dart';
import 'app/ui/pages/payments_page.dart';
import 'app/ui/pages/profile_page.dart';
import 'app/ui/pages/edit_profile_page.dart';
import 'app/ui/pages/referral_program_page.dart';
import 'app/ui/pages/app_settings_page.dart';
import 'app/ui/pages/terms_conditions_page.dart';
import 'app/ui/pages/user_agreements_page.dart';
import 'app/ui/pages/help_customer_service_page.dart';
import 'app/ui/pages/splash_screen.dart';
import 'app/ui/pages/notifications_page.dart'; // Added import for NotificationsPage
import 'app/utils/colors.dart';
import 'app/utils/translations.dart'; // Ensure this import is correct
import 'firebase_options.dart';
import 'app/binding/main_screen_binding.dart';
import 'app/binding/portfolio_binding.dart';
import 'app/binding/payments_binding.dart';
import 'app/binding/profile_binding.dart';
import 'app/ui/pages/fd_details_page.dart'; // Added import

// Utility function to format the current time
String getFormattedTime() {
  final now = DateTime.now();
  final formatter = DateFormat('hh:mm a z, MMMM dd, yyyy');
  return formatter.format(now); // e.g., 11:16 AM IST, May 26, 2025
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    print('Firebase initialized at ${getFormattedTime()}');
    print('Firebase Auth session persistence is handled automatically on Android');
  }

  // Enable Android-specific WebView implementation
  if (Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  // Initialize only the AuthController in main.dart
  Get.put(AuthController());

  // Lazily initialize other controllers to avoid heavy initialization at startup
  Get.lazyPut(() => HomeController());
  Get.lazyPut(() => FDPlansController());
  Get.lazyPut(() => PortfolioController());
  Get.lazyPut(() => PaymentsController());
  Get.lazyPut(() => ProfileController());
  Get.lazyPut(() => GoalBasedPlansController());
  Get.lazyPut(() => ComparisonController());
  Get.lazyPut(() => NotificationController()); // Added NotificationController

  runApp(const DhankuberApp());
}

class DhankuberApp extends StatelessWidget {
  const DhankuberApp({super.key});

  Future<String> _getInitialRoute() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

    if (kDebugMode) {
      print('Checking initial route at ${getFormattedTime()}...');
      print('Firebase Auth currentUser: ${auth.currentUser?.uid}, Phone: ${auth.currentUser?.phoneNumber}');
    }

    // Check if user is logged in
    if (auth.currentUser == null) {
      if (kDebugMode) {
        print('No signed-in user, redirecting to LoginPage');
      }
      return '/login';
    }

    // Check security settings
    String? biometricEnabled = await secureStorage.read(key: 'biometric_enabled');
    String? mpinEnabled = await secureStorage.read(key: 'mpin_enabled');
    bool isSecurityEnabled = biometricEnabled == 'true' || mpinEnabled == 'true';
    if (kDebugMode) {
      print('Security settings - Biometric: $biometricEnabled, MPIN: $mpinEnabled, Enabled: $isSecurityEnabled');
    }

    // Return route based on security settings
    if (isSecurityEnabled) {
      if (kDebugMode) {
        print('Security enabled, redirecting to SecurityCheckPage');
      }
      return '/security';
    } else {
      if (kDebugMode) {
        print('No security enabled, redirecting to MainScreen');
      }
      return '/main';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('Building DhankuberApp at ${getFormattedTime()}');
    }
    return GetMaterialApp(
      title: 'Dhankuber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryBrand,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 16,
            color: AppColors.primaryText,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: AppColors.primaryBrand,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      translations: AppTranslations(),
      locale: const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: '/splash',
      getPages: [
        GetPage(
          name: '/splash',
          page: () => SplashScreen(initialRouteFuture: _getInitialRoute()),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/otp',
          page: () => const OTPPage(),
        ),
        GetPage(
          name: '/name',
          page: () => const NameInputPage(),
        ),
        GetPage(
          name: '/security',
          page: () => const SecurityCheckPage(),
        ),
        GetPage(
          name: '/main',
          page: () => const MainScreen(),
          binding: MainScreenBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomePage(),
        ),
        GetPage(
          name: '/all_fd_plans',
          page: () => const AllFDPlansPage(),
        ),
        GetPage(
          name: '/trending_plans',
          page: () => TrendingPlansPage(), // Removed const since it's stateful
        ),
        GetPage(
          name: '/goal_based_plans',
          page: () => const GoalBasedPlansPage(),
        ),
        GetPage(
          name: '/fd_trial_section',
          page: () => const FDTrialSectionPage(),
        ),
        GetPage(
          name: '/fd_booking',
          page: () => const FDBookingPage(),
        ),
        GetPage(
          name: '/fd_comparison',
          page: () => const FDComparisonScreen(selectedFDPlans: []), // Added default empty list
        ),
        GetPage(
          name: '/fd_calculator',
          page: () => const FDCalculatorScreen(),
        ),
        GetPage(
          name: '/portfolio',
          page: () => const PortfolioPage(),
          binding: PortfolioBinding(),
        ),
        GetPage(
          name: '/payments',
          page: () => const PaymentsPage(),
          binding: PaymentsBinding(),
        ),
        GetPage(
          name: '/profile',
          page: () => const ProfilePage(),
          binding: ProfileBinding(),
        ),
        GetPage(
          name: '/edit_profile',
          page: () => const EditProfilePage(),
        ),
        GetPage(
          name: '/referral_program',
          page: () => const ReferralProgramPage(),
        ),
        GetPage(
          name: '/app_settings',
          page: () => const AppSettingsPage(),
        ),
        GetPage(
          name: '/terms_conditions',
          page: () => const TermsConditionsPage(),
        ),
        GetPage(
          name: '/user_agreements',
          page: () => const UserAgreementsPage(),
        ),
        GetPage(
          name: '/help_customer_service',
          page: () => const HelpCustomerServicePage(),
        ),
        GetPage(
          name: '/notifications',
          page: () => const NotificationsPage(), // Added route for NotificationsPage
        ),
        GetPage(
          name: '/fd_details',
          page: () {
            final goal = Get.arguments as Map<String, dynamic>?;
            return FDDetailsPage(
              goal: goal ?? {'goalName': 'Default', 'expectedReturn': '0.0% p.a.', 'tenure': '0 years', 'taxSaving': false},
            );
          },
        ),
      ],
    );
  }
}