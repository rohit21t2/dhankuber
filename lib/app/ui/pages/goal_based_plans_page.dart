import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/goal_based_plans_controller.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class GoalBasedPlansPage extends StatelessWidget {
  const GoalBasedPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final GoalBasedPlansController controller = Get.find<GoalBasedPlansController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Goal-Based FD Plans'),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: controller.goalBasedFDs.map((category) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category['category'],
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 12),
                ...category['goals'].map<Widget>((goal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildGoalCard(
                      goal,
                          () {
                        Get.to(() => FDDetailsPage(goal: {
                          'goalName': goal['bank'],
                          'expectedReturn': goal['expectedReturn'],
                          'tenure': goal['tenure'],
                          'taxSaving': goal['goalName'] == 'Tax-Saving FD',
                        }));
                      },
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
              ],
            );
          }).toList(),
        ),
      )),
    );
  }

  Widget _buildGoalCard(Map<String, dynamic> goal, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
                    goal['goalName'],
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
              'Bank: ${goal['bank']}',
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
              'Tenure: ${goal['tenure']}',
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
              'Interest Rate: ${goal['expectedReturn']}',
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
              'Issuer: ${goal['issuerType']}',
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