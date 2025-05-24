import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/fd_plans_controller.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'all_fd_plans_page.dart';
import 'trending_plans_page.dart';
import 'goal_based_plans_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    final FDPlansController fdController = Get.put(FDPlansController());

    return Scaffold(
      appBar: CustomAppBar(title: 'Dhankuber'),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Tab
              if (homeController.notifications.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latest Updates',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: 'Poppins',
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: homeController.notifications.length,
                        itemBuilder: (context, index) {
                          final notification = homeController.notifications[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentLightGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              notification,
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                color: AppColors.secondaryBrand,
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // Explore All FD Plans Card
              _buildStyledCard(
                context,
                title: 'Explore All FD Plans',
                subtitle: 'Discover Fixed Deposits from top banks',
                gradient: LinearGradient(
                  colors: [AppColors.primaryBrand, const Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                lottieAsset: 'assets/lottie/money_growth.json',
                onTap: () => Get.to(() => const AllFDPlansPage()),
              ),

              const SizedBox(height: 16),

              // Trending Plans Card
              _buildStyledCard(
                context,
                title: 'Trending FD Plans',
                subtitle: fdController.trendingPlans.isNotEmpty
                    ? '${fdController.trendingPlans.first['bank']} - ${fdController.trendingPlans.first['plan']}'
                    : 'Discover popular FD plans',
                gradient: LinearGradient(
                  colors: [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                lottieAsset: 'assets/lottie/trending.json',
                onTap: () => Get.to(() => const TrendingPlansPage()),
              ),

              const SizedBox(height: 16),

              // Goal-based Plans Card
              _buildStyledCard(
                context,
                title: 'Goal-based FD Plans',
                subtitle: 'Plans for Education, Retirement, Marriage',
                gradient: LinearGradient(
                  colors: [AppColors.accentLightGreen, const Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                lottieAsset: 'assets/lottie/goal.json',
                onTap: () => Get.to(() => const GoalBasedPlansPage()),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildStyledCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required LinearGradient gradient,
        required String lottieAsset,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 150,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Lottie Animation (Rounded, Smaller, Centered Vertically, Slightly Right)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ClipOval(
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(lottieAsset, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            // Text Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
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