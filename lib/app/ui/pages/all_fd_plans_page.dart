import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/fd_plans_controller.dart';
import '../widgets/fd_card_widget.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class AllFDPlansPage extends StatelessWidget {
  const AllFDPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FDPlansController controller = Get.find<FDPlansController>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: 'All FD Plans'),
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
                    hintText: 'Search FD plans...',
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

              // Category Filters
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildFilterButton(
                    context,
                    'All',
                    controller.selectedCategory.value == '',
                        () => controller.filterPlans(''),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    context,
                    'Tax Saving',
                    controller.selectedCategory.value == 'Tax Saving',
                        () => controller.filterPlans('Tax Saving'),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(
                    context,
                    'Senior Citizen',
                    controller.selectedCategory.value == 'Senior Citizen',
                        () => controller.filterPlans('Senior Citizen'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // All FD Plans
              Text(
                'All FD Plans',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              controller.filteredPlans.isEmpty
                  ? const Center(child: Text('No plans available'))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.filteredPlans.length,
                itemBuilder: (context, index) {
                  final plan = controller.filteredPlans[index];
                  return FDCardWidget(
                    plan: plan,
                    isFeatured: true,
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

  Widget _buildFilterButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBrand : AppColors.neutralLightGray,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'OpenSans',
            color: isSelected ? Colors.white : AppColors.primaryText,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}