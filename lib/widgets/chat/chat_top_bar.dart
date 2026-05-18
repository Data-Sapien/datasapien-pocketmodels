import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_color.dart';

/// Chat screen top bar: history (leading), model selector (center), settings and profile (trailing).
/// Profile shows a badge when [badgeCount] > 0.
class ChatTopBar extends StatelessWidget {
  const ChatTopBar({
    super.key,
    required this.onHistory,
    required this.onNewChat,
    required this.onModel,
    required this.onSettings,
    required this.onProfile,
    this.badgeCount = 0,
    this.modelName,
    this.modelState,
    this.modelProgress,
  });

  final VoidCallback onHistory;
  final VoidCallback onNewChat;
  final VoidCallback onModel;
  final VoidCallback onSettings;
  final VoidCallback onProfile;
  final int badgeCount;
  final String? modelName;
  final String? modelState;
  final double? modelProgress;

  static const double _barHeight = 56;
  static const double _pillSize = 40;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: _barHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _PillButton(
              iconAsset: AppAssetIcons.mainClockRotate,
              onTap: onHistory,
              size: _pillSize,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 8),
            _PillButton(
              iconAsset: AppAssetIcons.mainSquareAndPencil,
              onTap: onNewChat,
              size: _pillSize,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                child: _ModelSelectorPill(
                  modelName: modelName ??
                      AppLocalizations.of(context)!.chat_model_loading,
                  modelState: modelState,
                  modelProgress: modelProgress,
                  onTap: onModel,
                  colorScheme: colorScheme,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              clipBehavior: Clip.none,
              children: [
                _PillButton(
                  iconAsset: AppAssetIcons.mainChartBarHorizontalPage,
                  onTap: onProfile,
                  size: _pillSize,
                  colorScheme: colorScheme,
                ),
                if (badgeCount > 0) _Badge(count: badgeCount),
              ],
            ),
            const SizedBox(width: 8),
            _PillButton(
              iconAsset: AppAssetIcons.mainGearshape,
              onTap: onSettings,
              size: _pillSize,
              colorScheme: colorScheme,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.iconAsset,
    required this.onTap,
    required this.size,
    required this.colorScheme,
  });

  final String iconAsset;
  final VoidCallback onTap;
  final double size;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(size / 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModelSelectorPill extends StatelessWidget {
  const _ModelSelectorPill({
    required this.modelName,
    required this.modelState,
    required this.modelProgress,
    required this.onTap,
    required this.colorScheme,
  });

  final String modelName;
  final String? modelState;
  final double? modelProgress;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final state = modelState?.toLowerCase();
    final isLoading = state == 'loading';
    final isDownloading = state == 'downloading';
    final progressPct = ((modelProgress ?? 0) * 100).clamp(0, 100).round();
    final label = isDownloading && progressPct > 0
        ? '$modelName ($progressPct%)'
        : modelName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _backgroundColor(colorScheme),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _borderColor(colorScheme),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              if (isLoading)
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _statusColor(colorScheme),
                  ),
                )
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _statusColor(colorScheme),
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 12),
                Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface,
                          ) ??
                      const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    if (modelState == null) return colorScheme.primary;
    switch (modelState!.toLowerCase()) {
      case 'ready':
        return Colors.green;
      case 'error':
        return Colors.red;
      case 'downloading':
        return Colors.blue;
      default:
        return colorScheme.primary;
    }
  }

  Color _borderColor(ColorScheme colorScheme) {
    if (modelState == null) return AppColor.primaryTint.withValues(alpha: 0.3);
    switch (modelState!.toLowerCase()) {
      case 'loading':
        return Colors.orange;
      case 'downloading':
        return Colors.blue;
      default:
        return AppColor.primaryTint.withValues(alpha: 0.3);
    }
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    if (modelState == null) return colorScheme.surfaceContainerHighest;
    switch (modelState!.toLowerCase()) {
      case 'loading':
        return Colors.orange.withValues(alpha: 0.06);
      case 'downloading':
        return Colors.blue.withValues(alpha: 0.06);
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Positioned(
      top: -2,
      right: -2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
