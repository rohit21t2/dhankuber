import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;
  final Color shadowColor;
  final TextStyle? titleTextStyle;
  final double? leadingWidth;
  final double? titleSpacing; // Added parameter for title spacing

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = AppColors.accentLightGreen,
    this.elevation = 2,
    this.shadowColor = const Color(0x80E0E0E0),
    this.titleTextStyle,
    this.leadingWidth,
    this.titleSpacing, // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title.tr, // Use .tr for localization
        style: titleTextStyle ?? // Use provided style or fallback to default
            Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.primaryText,
            ),
      ),
      leading: leading,
      leadingWidth: leadingWidth,
      titleSpacing: titleSpacing, // Pass to AppBar
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      shadowColor: shadowColor,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}