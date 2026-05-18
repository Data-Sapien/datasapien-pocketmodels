import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import '../../theme/app_font.dart';

/// Single key-value row for My Data tab. Mirrors iOS [MyDataCell].
class MyDataRow extends StatelessWidget {
  const MyDataRow({
    super.key,
    required this.keyText,
    required this.value,
    required this.isNative,
    this.onTap,
  });

  final String keyText;
  final String value;
  final bool isNative;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final keyColor = isNative
        ? AppColor.textSecondary(context)
        : AppColor.primaryTint;
    final iconColor = isNative
        ? AppColor.textSecondary(context).withValues(alpha: 0.6)
        : AppColor.primaryTint;

    return Material(
      color: AppColor.primaryBackground(context),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isNative ? Icons.lock : Icons.verified,
                          size: 16,
                          color: iconColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            keyText.toUpperCase(),
                            style: AppFont.captionBold.copyWith(color: keyColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      value,
                      style: AppFont.body.copyWith(
                        color: AppColor.textPrimary(context),
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: AppColor.textSecondary(context).withValues(alpha: 0.4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
