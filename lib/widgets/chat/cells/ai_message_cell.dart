import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';
import '../chat_markdown.dart';

/// Callbacks for AI message actions; mirrors iOS AIMessageCellDelegate.
typedef OnCopyAiMessage = void Function(String text);
typedef OnShareAiMessage = void Function(String text);

/// AI message bubble; left-aligned, markdown, code blocks, streaming/error. Mirrors iOS AIMessageCell.
class AIMessageCell extends StatelessWidget {
  const AIMessageCell({
    super.key,
    required this.message,
    this.onCopy,
    this.onShare,
    this.onRetry,
  });

  final ChatMessage message;
  final OnCopyAiMessage? onCopy;
  final OnShareAiMessage? onShare;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isStreamingEmpty = message.isStreaming && message.text.isEmpty;
    final showActions = !message.isStreaming && !message.isError;
    final isError = message.isError;
    final borderColor = isError
        ? Colors.red.withValues(alpha: 0.3)
        : AppColor.primaryTint.withValues(alpha: 0.1);
    final bgColor = isError
        ? Colors.red.withValues(alpha: 0.05)
        : AppColor.secondaryBackground(context);

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColor.primaryTint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: AppColor.primaryTint,
            ),
          ),
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width - 40 - 28 - 8,
              ),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border.all(color: borderColor, width: 1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      isStreamingEmpty ? 8 : 0,
                    ),
                    child: isStreamingEmpty
                        ? const Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 12),
                              Text(' ', style: TextStyle(fontSize: 15)),
                            ],
                          )
                        : ChatMarkdown(
                            data: message.text,
                            textColor: isError
                                ? Colors.red.shade700
                                : AppColor.textPrimary(context),
                          ),
                  ),
                  if (showActions) ...[
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      height: 1,
                      color: AppColor.primaryTint.withValues(alpha: 0.08),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          if (onCopy != null)
                            _ActionButton(
                              icon: Icons.copy,
                              label: 'Copy',
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: message.text));
                                onCopy!(message.text);
                              },
                            ),
                          if (onShare != null) ...[
                            const SizedBox(width: 20),
                            _ActionButton(
                              icon: Icons.share,
                              label: 'Share',
                              onTap: () => onShare!(message.text),
                            ),
                          ],
                          const Spacer(),
                          if (message.metrics != null) ...[
                            Text(
                              '${message.metrics!.tokensPerSecond.toStringAsFixed(1)} t/s ⚡️ ${message.metrics!.maxTokens > 0 ? ((message.metrics!.usedTokens / message.metrics!.maxTokens) * 100).round() : 0}% ctx',
                              style: AppFont.caption.copyWith(
                                color: AppColor.textSecondary(context).withValues(alpha: 0.6),
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  if (message.isError && onRetry != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: TextButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: AppColor.textSecondary(context)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColor.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
