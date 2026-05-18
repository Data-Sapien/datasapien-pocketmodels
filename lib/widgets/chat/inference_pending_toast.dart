import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_icons.dart';
import '../../viewmodels/main_chat_view_model.dart';

/// Bottom inference approval card mirroring iOS [InferenceToastView].
class InferencePendingToast extends StatelessWidget {
  const InferencePendingToast({
    super.key,
    required this.pending,
    required this.onApprove,
    required this.onReject,
  });

  final PendingInference pending;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  static String _capitalizedKey(String key) {
    if (key.isEmpty) return key;
    return '${key[0].toUpperCase()}${key.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final valueLine = '${_capitalizedKey(pending.key)}: ${pending.value}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: surface.withValues(alpha: isDark ? 0.45 : 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  AppIcons.sparkles,
                  size: 16,
                  color: AppColor.primaryTint,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.inference_toast_title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColor.textSecondary(context),
                        ),
                      ),
                      Text(
                        valueLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton.icon(
                        onPressed: onApprove,
                        icon: const Icon(AppIcons.checkmark, size: 12),
                        label: Text(
                          l10n.inference_toast_add,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColor.primaryTint,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: const StadiumBorder(),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: onReject,
                        style: IconButton.styleFrom(
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.9),
                          foregroundColor: AppColor.textSecondary(context),
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(AppIcons.xmark, size: 10),
                        tooltip: l10n.inference_toast_reject,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Vertical stack of [InferencePendingToast] above the input (iOS InferenceToastManager stack).
class InferencePendingToastStack extends StatelessWidget {
  const InferencePendingToastStack({
    super.key,
    required this.pending,
    required this.onResolved,
  });

  final List<PendingInference> pending;
  final Future<void> Function(PendingInference pending, bool approved) onResolved;

  static double _maxStackHeight(double parentMaxHeight) {
    if (!parentMaxHeight.isFinite || parentMaxHeight <= 0) return 240;
    return math.min(260, math.max(100, parentMaxHeight * 0.35));
  }

  @override
  Widget build(BuildContext context) {
    if (pending.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cap = _maxStackHeight(constraints.maxHeight);
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: cap),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < pending.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    InferencePendingToast(
                      pending: pending[i],
                      onApprove: () => unawaited(onResolved(pending[i], true)),
                      onReject: () => unawaited(onResolved(pending[i], false)),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
