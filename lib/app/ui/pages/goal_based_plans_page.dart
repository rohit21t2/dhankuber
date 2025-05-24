import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/fd_plans_controller.dart';
import '../widgets/fd_card_widget.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class GoalBasedPlansPage extends StatelessWidget {
  const GoalBasedPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FDPlansController controller = Get.find<FDPlansController>();
    final TextEditingController searchController = TextEditingController();

    return Scaffold(
      appBar: CustomAppBar(title: 'Goal-based FD Plans'),
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
                    hintText: 'Search goal-based plans...',
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

              // Goal Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildGoalButton(
                    context,
                    'Education',
                    controller.selectedGoal.value == 'Education',
                        () => controller.selectGoal('Education'),
                  ),
                  const SizedBox(width: 8),
                  _buildGoalButton(
                    context,
                    'Retirement',
                    controller.selectedGoal.value == 'Retirement',
                        () => controller.selectGoal('Retirement'),
                  ),
                  const SizedBox(width: 8),
                  _buildGoalButton(
                    context,
                    'Marriage',
                    controller.selectedGoal.value == 'Marriage',
                        () => controller.selectGoal('Marriage'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Goal-based Plans
              Text(
                '${controller.selectedGoal.value} Plans',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Poppins',
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              _buildGoalSection(
                context,
                controller,
                controller.selectedGoal.value,
                controller.selectedGoal.value == 'Education'
                    ? AppColors.accentLightGreen
                    : controller.selectedGoal.value == 'Retirement'
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFFCE4EC),
              ),
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildGoalButton(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
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

  Widget _buildGoalSection(BuildContext context, FDPlansController controller, String goal, Color bgColor) {
    final goalPlans = controller.getPlansByGoal(goal);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Poppins',
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          goalPlans.isEmpty
              ? const Text('No plans available for this goal')
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: goalPlans.length,
            itemBuilder: (context, index) {
              final plan = goalPlans[index];
              return FDCardWidget(
                plan: plan,
                onTap: () => Get.to(() => FDDetailsPage(plan: plan)),
              );
            },
          ),
        ],
      ),
    );
  }
}