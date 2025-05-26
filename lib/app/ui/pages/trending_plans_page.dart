import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/trending_plans_controller.dart';
import '../../utils/colors.dart';
import 'fd_details_page.dart';

class TrendingPlansPage extends StatefulWidget {
  const TrendingPlansPage({super.key});

  @override
  State<TrendingPlansPage> createState() => _TrendingPlansPageState();
}

class _TrendingPlansPageState extends State<TrendingPlansPage> {
  late TrendingPlansController controller;
  final String controllerTag = 'TrendingPlansPageController';

  @override
  void initState() {
    super.initState();
    controller = Get.put(TrendingPlansController(), tag: controllerTag);
  }

  @override
  void dispose() {
    Get.delete<TrendingPlansController>(tag: controllerTag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'trending_fds'.tr,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryText,
          ),
        ),
        backgroundColor: AppColors.background,
      ),
      body: Obx(() => ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.filteredTrendingFDs.length,
        itemBuilder: (context, index) {
          final fd = controller.filteredTrendingFDs[index];
          return GestureDetector(
            onTap: () {
              Get.to(() => FDDetailsPage(goal: {
                'goalName': fd['bank'],
                'expectedReturn': fd['interestRate'],
                'tenure': fd['plan'],
                'taxSaving': fd['taxSaving'],
              }));
            },
            child: Card(
              color: AppColors.primaryBrand, // Orange color matching HomePage
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
            ),
          );
        },
      )),
    );
  }
}