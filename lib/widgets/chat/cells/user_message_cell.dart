import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../chat_markdown.dart';

/// User message bubble; right-aligned, primary tint background. Mirrors iOS UserMessageCell.
class UserMessageCell extends StatelessWidget {
  const UserMessageCell({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
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
            color: AppColor.primaryTint,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
          ),
          child: ChatMarkdown(
            data: message.text,
            textColor: AppColor.buttonText,
          ),
        ),
      ),
    );
  }
}
