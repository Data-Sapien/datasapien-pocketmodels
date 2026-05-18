import 'package:flutter/material.dart';

import '../theme/app_color.dart';

/// App marketing image from iOS `appImage` asset (splash / onboarding).
class AppMarketingLogo extends StatelessWidget {
  const AppMarketingLogo({
    super.key,
    required this.size,
    required this.borderRadius,
  });

  final double size;
  final double borderRadius;

  static const assetPath = 'assets/images/app_image.png';

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColor.primaryTint.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Icon(
            Icons.smart_toy_outlined,
            size: size * 0.53,
            color: AppColor.primaryTint,
          ),
        ),
      ),
    );
  }
}
