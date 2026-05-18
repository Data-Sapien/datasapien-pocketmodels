import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';
import '../chat_markdown.dart';

/// Journey summary card in chat; full-width, "Journey Step" title. Mirrors iOS JourneyMessageCell.
class JourneyMessageCell extends StatelessWidget {
  const JourneyMessageCell({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColor.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.primaryTint.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Journey Step',
            style: AppFont.bodyBold.copyWith(
              color: AppColor.textPrimary(context),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          ChatMarkdown(
            data: message.text,
            textColor: AppColor.textSecondary(context),
          ),
        ],
      ),
    );
  }
}
