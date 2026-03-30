import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class TuttaButton extends StatelessWidget {
  const TuttaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.color,
    this.textColor,
    this.minWidth = double.infinity,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Widget? icon;
  final Color? color;
  final Color? textColor;
  final double minWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(minWidth, height),
          foregroundColor: color ?? AppColors.primary,
          side: BorderSide(color: color ?? AppColors.primary),
        ),
        child: _buildChild(),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(minWidth, height),
        backgroundColor: color,
        foregroundColor: textColor,
      ),
      child: _buildChild(),
    );
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.labelLarge),
        ],
      );
    }

    return Text(label, style: AppTextStyles.labelLarge);
  }
}
