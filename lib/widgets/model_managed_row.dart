import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/app_localizations.dart';
import '../services/model_selector_source.dart';
import '../theme/app_color.dart';
import '../theme/app_asset_icons.dart';
import '../theme/app_font.dart';
import '../theme/app_icons.dart';
import '../utils/media_url_helper.dart';

/// One managed-model row: thumbnail, title, optional subtitle, selection border,
/// and trailing download / progress / queued / selected / downloaded states.
/// Matches iOS [BottomSheetModelCell] behavior. Parent decides what [onDownloadTap] does (e.g. select-only in onboarding).
class ModelManagedRow extends StatelessWidget {
  /// Fixed trailing column so download / checkmark / progress align across rows regardless of label length.
  static const double _trailingSlotWidth = 44;
  static const double _trailingIconSize = 20;

  const ModelManagedRow({
    super.key,
    required this.model,
    required this.isDownloaded,
    required this.isSelected,
    required this.isDownloading,
    required this.isQueued,
    required this.progress,
    required this.onTap,
    required this.onDownloadTap,
  });

  final ManagedModelItem model;
  final bool isDownloaded;
  final bool isSelected;
  final bool isDownloading;
  final bool isQueued;
  final double? progress;
  final VoidCallback onTap;
  final VoidCallback onDownloadTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = model.resolvedDisplayTitle(l10n.default_model);
    final subtitle = model.subtitle;
    final imageUri = resolveManagedModelImageUrl(model.imageUrl);

    return Material(
      color: AppColor.secondaryBackground(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppColor.primaryTint : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: imageUri != null
                      ? Image.network(
                          imageUri.toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder(context),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return _placeholder(context);
                          },
                        )
                      : _placeholder(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Text(
                          title,
                          style: AppFont.bodyBold.copyWith(
                            color: AppColor.textPrimary(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (model.multimodal) _VisionBadge(),
                      ],
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppFont.caption.copyWith(
                          color: AppColor.textSecondary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _trailing(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    return ColoredBox(
      color: AppColor.textSecondary(context).withValues(alpha: 0.12),
      child: Icon(
        AppIcons.cubeBoxFill,
        color: AppColor.textSecondary(context),
        size: 22,
      ),
    );
  }

  Widget _trailingSlot(Widget child) {
    return SizedBox(
      width: _trailingSlotWidth,
      height: _trailingSlotWidth,
      child: Center(child: child),
    );
  }

  Widget _trailing(BuildContext context, AppLocalizations l10n) {
    if (isDownloading) {
      final p = progress;
      if (p != null) {
        return _trailingSlot(
          Text(
            '${(p.clamp(0.0, 1.0) * 100).round()}%',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppFont.caption.copyWith(
              color: AppColor.primaryTint,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }
      return _trailingSlot(
        SizedBox(
          width: _trailingIconSize,
          height: _trailingIconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColor.primaryTint,
          ),
        ),
      );
    }
    if (isQueued) {
      return _trailingSlot(
        Text(
          l10n.model_row_queued,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppFont.caption.copyWith(
            color: AppColor.textSecondary(context),
          ),
        ),
      );
    }
    if (isSelected) {
      return _trailingSlot(
        Icon(
          AppIcons.checkmarkCircleFill,
          color: AppColor.primaryTint,
          size: _trailingIconSize,
        ),
      );
    }
    if (isDownloaded) {
      return _trailingSlot(
        Tooltip(
          message: l10n.model_row_downloaded,
          child: Semantics(
            label: l10n.model_row_downloaded,
            child: Icon(
              AppIcons.arrowDownCircle,
              size: _trailingIconSize,
              color: Colors.green,
            ),
          ),
        ),
      );
    }
    return _trailingSlot(
      IconButton(
        onPressed: onDownloadTap,
        tooltip: l10n.model_row_download,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(
          width: _trailingSlotWidth,
          height: _trailingSlotWidth,
        ),
        iconSize: _trailingIconSize,
        style: IconButton.styleFrom(
          foregroundColor: AppColor.primaryTint,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        icon: SvgPicture.asset(
          AppAssetIcons.mainIcloudAndArrowDown,
          width: _trailingIconSize,
          height: _trailingIconSize,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            AppColor.primaryTint,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

class _VisionBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Vision',
        style: AppFont.caption.copyWith(
          color: Colors.deepPurple,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
