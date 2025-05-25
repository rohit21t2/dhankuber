import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/fd_plans_controller.dart';
import '../../controllers/home_controller.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class AllFDPlansPage extends StatelessWidget {
  const AllFDPlansPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FDPlansController fdPlansController = Get.find<FDPlansController>();
    final HomeController homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: const CustomAppBar(title: 'All FD Plans'),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort By Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sort By:',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                DropdownButton<String>(
                  value: fdPlansController.sortBy.value,
                  items: <String>['Highest Return', 'Shortest Tenure']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(
                            value == 'Highest Return' ? Icons.trending_up : Icons.calendar_today,
                            size: 20,
                            color: AppColors.primaryBrand,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            value,
                            style: const TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 16,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    fdPlansController.updateSortBy(newValue);
                  },
                  underline: Container(),
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.primaryBrand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter By Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter By:',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'Poppins',
                    color: AppColors.primaryText,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.primaryBrand,
                    size: 28,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => FilterBottomSheet(fdPlansController: fdPlansController),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List of FDs
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: fdPlansController.filteredFDs.length,
              itemBuilder: (context, index) {
                final fd = fdPlansController.filteredFDs[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFDCard(fd, () {
                    Get.to(() => FDDetailsPage(goal: {
                      'goalName': fd['bank'],
                      'expectedReturn': fd['interestRate'],
                      'tenure': fd['plan'],
                      'duration': fd['plan'],
                      'taxSaving': fd['taxSaving'],
                    }));
                  }),
                );
              },
            ),
          ],
        ),
      )),
    );
  }

  // FD Card UI (same as HomePage All FDs)
  Widget _buildFDCard(Map<String, dynamic> fd, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryBrand,
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

// Filter Bottom Sheet
class FilterBottomSheet extends StatelessWidget {
  final FDPlansController fdPlansController;

  const FilterBottomSheet({super.key, required this.fdPlansController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter By:',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Poppins',
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 16),

            // Tenure Range Filter
            const Text(
              'Tenure Range (Months)',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: AppColors.primaryText,
              ),
            ),
            RangeSlider(
              values: fdPlansController.tenureRange.value,
              min: 12,
              max: 60,
              divisions: 48,
              labels: RangeLabels(
                fdPlansController.tenureRange.value.start.round().toString(),
                fdPlansController.tenureRange.value.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                fdPlansController.updateTenureRange(values);
              },
              activeColor: AppColors.primaryBrand,
              inactiveColor: AppColors.secondaryText,
            ),

            // Return Range Filter
            const Text(
              'Return Range (% p.a.)',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 16,
                color: AppColors.primaryText,
              ),
            ),
            RangeSlider(
              values: fdPlansController.returnRange.value,
              min: 7.0,
              max: 9.5,
              divisions: 25,
              labels: RangeLabels(
                fdPlansController.returnRange.value.start.toStringAsFixed(1),
                fdPlansController.returnRange.value.end.toStringAsFixed(1),
              ),
              onChanged: (RangeValues values) {
                fdPlansController.updateReturnRange(values);
              },
              activeColor: AppColors.primaryBrand,
              inactiveColor: AppColors.secondaryText,
            ),

            // Tax Saving Only Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tax Saving Only',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                Switch(
                  value: fdPlansController.taxSavingOnly.value,
                  onChanged: (value) {
                    fdPlansController.toggleTaxSaving(value);
                  },
                  activeColor: AppColors.primaryBrand,
                ),
              ],
            ),

            // Senior Citizen Rate Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Senior Citizen Rate',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                Switch(
                  value: fdPlansController.seniorCitizenRate.value,
                  onChanged: (value) {
                    fdPlansController.toggleSeniorCitizenRate(value);
                  },
                  activeColor: AppColors.primaryBrand,
                ),
              ],
            ),

            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}