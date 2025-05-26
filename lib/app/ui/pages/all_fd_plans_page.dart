import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/fd_plans_controller.dart';
import '../components/custom_appbar.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class AllFDPlansPage extends StatefulWidget {
  const AllFDPlansPage({super.key});

  @override
  State<AllFDPlansPage> createState() => _AllFDPlansPageState();
}

class _AllFDPlansPageState extends State<AllFDPlansPage> {
  late FDPlansController fdPlansController;
  final String controllerTag = 'AllFDPlansController'; // Unique tag for this page

  @override
  void initState() {
    super.initState();
    // Create a tagged instance of FDPlansController for this page
    fdPlansController = Get.put(FDPlansController(), tag: controllerTag);
  }

  @override
  void dispose() {
    // Delete the tagged controller instance when the page is disposed
    Get.delete<FDPlansController>(tag: controllerTag);
    super.dispose();
  }

  // Method to show the filter UI in a dialog
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter By',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontFamily: 'Poppins',
              color: AppColors.primaryText,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tenure Range Filter
                const Text(
                  'Tenure Range (Months)',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                Obx(() => RangeSlider(
                  values: fdPlansController.tempTenureRange.value, // Use temporary value
                  min: 12,
                  max: 60,
                  divisions: 48,
                  labels: RangeLabels(
                    fdPlansController.tempTenureRange.value.start.round().toString(),
                    fdPlansController.tempTenureRange.value.end.round().toString(),
                  ),
                  onChanged: (RangeValues values) {
                    fdPlansController.updateTempTenureRange(values);
                  },
                  activeColor: AppColors.primaryBrand,
                  inactiveColor: AppColors.secondaryText,
                )),

                // Return Range Filter
                const Text(
                  'Return Range (% p.a.)',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                Obx(() => RangeSlider(
                  values: fdPlansController.tempReturnRange.value, // Use temporary value
                  min: 7.0,
                  max: 9.5,
                  divisions: 25,
                  labels: RangeLabels(
                    fdPlansController.tempReturnRange.value.start.toStringAsFixed(1),
                    fdPlansController.tempReturnRange.value.end.toStringAsFixed(1),
                  ),
                  onChanged: (RangeValues values) {
                    fdPlansController.updateTempReturnRange(values);
                  },
                  activeColor: AppColors.primaryBrand,
                  inactiveColor: AppColors.secondaryText,
                )),

                // Tax Saving Only Filter
                Obx(() => Row(
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
                      value: fdPlansController.tempTaxSavingOnly.value, // Use temporary value
                      onChanged: (value) {
                        fdPlansController.toggleTempTaxSaving(value);
                      },
                      activeColor: AppColors.primaryBrand,
                    ),
                  ],
                )),

                // Senior Citizen Rate Filter
                Obx(() => Row(
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
                      value: fdPlansController.tempSeniorCitizenRate.value, // Use temporary value
                      onChanged: (value) {
                        fdPlansController.toggleTempSeniorCitizenRate(value);
                      },
                      activeColor: AppColors.primaryBrand,
                    ),
                  ],
                )),

                // FD Type Filter (Multi-selection)
                const SizedBox(height: 16),
                const Text(
                  'By FD Type',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    'Regular FD',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedFDTypes.contains('Regular'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempFDType('Regular', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    'Tax Saving FD',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedFDTypes.contains('TaxSaving'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempFDType('TaxSaving', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    'Senior Citizen FD',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedFDTypes.contains('SeniorCitizen'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempFDType('SeniorCitizen', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    'NRE/NRO FD',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedFDTypes.contains('NRE_NRO'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempFDType('NRE_NRO', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),

                // Minimum Deposit Amount Filter (Multi-selection)
                const SizedBox(height: 16),
                const Text(
                  'By Minimum Deposit Amount',
                  style: TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    '₹1,000 - ₹5,000',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedDepositRanges.contains('1000-5000'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempDepositRange('1000-5000', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    '₹5,001 - ₹50,000',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedDepositRanges.contains('5001-50000'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempDepositRange('5001-50000', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),
                Obx(() => CheckboxListTile(
                  title: const Text(
                    '₹50,001 and above',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      color: AppColors.primaryText,
                    ),
                  ),
                  value: fdPlansController.tempSelectedDepositRanges.contains('50001+'), // Use temporary value
                  onChanged: (bool? value) {
                    fdPlansController.toggleTempDepositRange('50001+', value ?? false);
                  },
                  activeColor: AppColors.primaryBrand,
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without applying
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 16,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                fdPlansController.applyTempFiltersAndSort();
                Navigator.pop(context); // Close the dialog after applying filters
              },
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
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.neutralLightGray,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  value: fdPlansController.tempSortBy.value, // Use temporary value
                  items: <String>['Highest Return', 'Shortest Tenure', 'Highest Tenure', 'Minimum Deposit Amount']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        children: [
                          Icon(
                            value == 'Highest Return'
                                ? Icons.trending_up
                                : value == 'Shortest Tenure'
                                ? Icons.calendar_today
                                : value == 'Highest Tenure'
                                ? Icons.calendar_today_outlined
                                : Icons.account_balance_wallet,
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
                    fdPlansController.updateTempSortBy(newValue);
                    fdPlansController.applyTempFiltersAndSort(); // Apply sorting immediately
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

            // Filter By Section (Styled like Sort By Dropdown)
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
                GestureDetector(
                  onTap: () {
                    _showFilterDialog(context);
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 20,
                        color: AppColors.primaryBrand,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Filters',
                        style: const TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 16,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primaryBrand,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

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