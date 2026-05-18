import 'package:flutter/material.dart';

import '../../../models/chat_message.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';

/// Web search status/results bubble; left-aligned. Mirrors iOS WebSearchBubbleCell.
class WebSearchBubbleCell extends StatelessWidget {
  const WebSearchBubbleCell({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final type = message.type;
    if (type is! WebSearchMessageType) return const SizedBox.shrink();
    final query = type.query;
    final results = type.results;
    final isLoading = results == null;
    final hasResults = results != null && results.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.textSecondary(context).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isLoading
                    ? Icons.language
                    : hasResults
                        ? Icons.verified
                        : Icons.warning_amber_rounded,
                size: 20,
                color: hasResults
                    ? Colors.green
                    : isLoading
                        ? AppColor.primaryTint
                        : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isLoading
                      ? (query.isEmpty ? 'Preparing search...' : 'Searching for "$query"...')
                      : hasResults
                          ? 'Found ${results.length} sources'
                          : 'No relevant sources found.',
                  style: AppFont.bodyBold.copyWith(
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (hasResults) ...[
            const SizedBox(height: 16),
            ...results.map((r) {
              final host = Uri.tryParse(r.url)?.host ?? r.url;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.link,
                      size: 20,
                      color: AppColor.textSecondary(context).withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: AppFont.caption.copyWith(
                              color: AppColor.textPrimary(context),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            host,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF888888),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
