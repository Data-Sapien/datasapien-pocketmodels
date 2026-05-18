import 'dart:io';

import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import 'ai_message_cell.dart';
import 'document_message_cell.dart';
import 'image_message_cell.dart';
import 'journey_message_cell.dart';
import 'memory_update_cell.dart';
import 'user_message_cell.dart';
import 'web_search_bubble_cell.dart';

/// Builds the appropriate cell widget for a [ChatMessage] type.
Widget buildChatMessageCell(
  BuildContext context, {
  required ChatMessage message,
  OnCopyAiMessage? onCopyAi,
  OnShareAiMessage? onShareAi,
  VoidCallback? onRetryAi,
}) {
  switch (message.type) {
    case UserMessageType():
      return UserMessageCell(message: message);
    case AiMessageType():
      return AIMessageCell(
        message: message,
        onCopy: onCopyAi,
        onShare: onShareAi,
        onRetry: onRetryAi,
      );
    case JourneyMessageType():
      return JourneyMessageCell(message: message);
    case MemoryUpdateMessageType():
      return MemoryUpdateCell(message: message);
    case DocumentMessageType():
      return DocumentMessageCell(message: message);
    case WebSearchMessageType():
      return WebSearchBubbleCell(message: message);
    case ImageMessageType():
      return ImageMessageCell(
        message: message,
        onTap: () async {
          final path = (message.type as ImageMessageType).path;
          if (path.isEmpty) return;
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => _ImagePreviewDialog(path: path),
          );
        },
      );
  }
}

class _ImagePreviewDialog extends StatelessWidget {
  const _ImagePreviewDialog({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: Image.file(
                File(path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              color: Colors.white,
              iconSize: 28,
            ),
          ),
        ],
      ),
    );
  }
}
