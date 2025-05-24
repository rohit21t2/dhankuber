import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.primaryText,
        ),
      ),
      backgroundColor: AppColors.accentLightGreen,
      elevation: 2,
      shadowColor: AppColors.neutralLightGray.withOpacity(0.5),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}