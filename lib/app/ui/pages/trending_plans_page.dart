import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/fd_plans_controller.dart';
import '../widgets/fd_card_widget.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class TrendingPlansPage extends StatelessWidget {
  const TrendingPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FDPlansController controller = Get.find<FDPlansController>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: 'Trending FD Plans'),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: AppColors.neutralLightGray,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search trending plans...',
                    hintStyle: TextStyle(
                      fontFamily: 'OpenSans',
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.secondaryText,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                  onChanged: (value) => controller.searchPlans(value),
                ),
              ),
              const SizedBox(height: 24),

              // Trending Plans
              Text(
                'Trending Plans',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              controller.trendingPlans.isEmpty
                  ? const Center(child: Text('No trending plans available'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.trendingPlans.length,
                itemBuilder: (context, index) {
                  final plan = controller.trendingPlans[index];
                  return FDCardWidget(
                    plan: plan,
                    isTrending: true,
                    onTap: () => Get.to(() => FDDetailsPage(plan: plan)),
                  );
                },
              ),
            ],
          ),
        ),
      )),
    );
  }
}