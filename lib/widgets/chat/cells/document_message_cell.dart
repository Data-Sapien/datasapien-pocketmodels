import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';

/// Document attachment bubble; right-aligned, doc icon + filename. Mirrors iOS DocumentMessageCell.
class DocumentMessageCell extends StatelessWidget {
  const DocumentMessageCell({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final filename = message.type is DocumentMessageType
        ? (message.type as DocumentMessageType).name
        : message.text;

    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width - 60,
          minWidth: 60,
        ),
        child: Container(
          margin: const EdgeInsets.only(left: 60, top: 8, bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description,
                size: 24,
                color: AppColor.primaryTint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      filename,
                      style: AppFont.bodyBold.copyWith(
                        color: AppColor.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.attached_document_subtitle,
                      style: AppFont.caption.copyWith(
                        color: AppColor.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
