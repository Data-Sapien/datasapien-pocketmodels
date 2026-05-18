import 'dart:io';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';

/// Image attachment bubble; right-aligned thumbnail + caption. Mirrors iOS ImageMessageCell.
class ImageMessageCell extends StatelessWidget {
  const ImageMessageCell({
    super.key,
    required this.message,
    this.onTap,
  });

  final ChatMessage message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final path = message.type is ImageMessageType
        ? (message.type as ImageMessageType).path
        : '';

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width - 60,
          minWidth: 60,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 60, top: 8, bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.secondaryBackground(context),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border.all(
                color: AppColor.primaryTint.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: path.isEmpty
                        ? const _PlaceholderThumb()
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const _PlaceholderThumb(),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context)!.attached_image_subtitle,
                  style: AppFont.caption.copyWith(
                    color: AppColor.textSecondary(context),
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

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColor.textSecondary(context).withValues(alpha: 0.12),
      child: Icon(
        Icons.photo_outlined,
        size: 40,
        color: AppColor.textSecondary(context),
      ),
    );
  }
}

