import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color backgroundColor;
  final double elevation;
  final Color shadowColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.backgroundColor = AppColors.accentLightGreen, // Default to current background color
    this.elevation = 2, // Default to current elevation
    this.shadowColor = const Color(0x80E0E0E0), // Approximate AppColors.neutralLightGray.withOpacity(0.5)
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
          color: AppColors.primaryText,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}