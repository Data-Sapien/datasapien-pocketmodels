import 'package:flutter/material.dart';

import '../../theme/app_color.dart';
import '../../theme/app_font.dart';

/// Settings list row matching iOS SettingsRowView: 56×56 icon, 20pt card radius, min height ~80.
///
/// Provide exactly one of [icon] or [leading] for the left glyph (iOS SF Symbol parity uses [leading]).
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.showTrailingArrow = true,
    this.onTap,
  }) : assert(
          (icon != null) != (leading != null),
          'Provide exactly one of icon or leading',
        );

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final bool showTrailingArrow;
  final VoidCallback? onTap;

  static const Color _iconBackground = Color(0xFFF0F7FF);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Material(
        color: AppColor.primaryBackground(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 80),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _iconBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: leading ??
                        Icon(icon!, color: AppColor.primaryTint, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppFont.bodyBold.copyWith(
                            fontSize: 17,
                            color: AppColor.textPrimary(context),
                          ),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: AppFont.caption.copyWith(
                              fontSize: 13,
                              color: AppColor.textSecondary(context)
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (showTrailingArrow)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColor.textSecondary(context)
                          .withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
