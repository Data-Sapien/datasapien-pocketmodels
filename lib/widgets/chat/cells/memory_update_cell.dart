import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';

/// "Memory updated" style message; centered pill with brain icon. Mirrors iOS MemoryUpdateCell.
class MemoryUpdateCell extends StatelessWidget {
  const MemoryUpdateCell({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(minHeight: 32),
        decoration: BoxDecoration(
          color: AppColor.secondaryBackground(context).withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColor.primaryTint.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 16,
              color: AppColor.primaryTint,
            ),
            const SizedBox(width: 8),
            Text(
              message.text.isNotEmpty ? message.text : 'Thinking...',
              style: AppFont.caption.copyWith(
                color: AppColor.textSecondary(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
