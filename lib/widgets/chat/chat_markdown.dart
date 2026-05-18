import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import 'code_block_view.dart';

/// Segment from parsing markdown (text vs code block).
class _MarkdownSegment {
  const _MarkdownSegment({required this.isCode, required this.content, this.language});
  final bool isCode;
  final String content;
  final String? language;
}

/// Parses markdown and returns text/code segments (mirrors iOS MarkdownParser).
List<_MarkdownSegment> _parseToSegments(String text) {
  final segments = <_MarkdownSegment>[];
  // Match fenced code: ```language?\n code ```
  final codeBlockPattern = RegExp(r'```([a-zA-Z0-9]*)\n?([\s\S]*?)```');
  var lastEnd = 0;
  for (final match in codeBlockPattern.allMatches(text)) {
    if (match.start > lastEnd) {
      segments.add(_MarkdownSegment(
        isCode: false,
        content: text.substring(lastEnd, match.start),
      ));
    }
    final lang = match.group(1);
    final code = (match.group(2) ?? '').trim();
    segments.add(_MarkdownSegment(
      isCode: true,
      content: code,
      language: lang != null && lang.isNotEmpty ? lang : null,
    ));
    lastEnd = match.start + match.group(0)!.length;
  }
  if (lastEnd < text.length) {
    segments.add(_MarkdownSegment(isCode: false, content: text.substring(lastEnd)));
  }
  if (segments.isEmpty && text.isNotEmpty) {
    segments.add(_MarkdownSegment(isCode: false, content: text));
  }
  return segments;
}

/// Renders markdown with code blocks as [CodeBlockView]; uses app theme.
class ChatMarkdown extends StatelessWidget {
  const ChatMarkdown({
    super.key,
    required this.data,
    this.selectable = false,
    this.textColor,
  });

  final String data;
  final bool selectable;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final color = textColor ?? AppColor.textPrimary(context);
    final segments = _parseToSegments(data);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((s) {
        if (s.isCode) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: CodeBlockView(code: s.content, language: s.language),
          );
        }
        return MarkdownBody(
          data: s.content,
          selectable: selectable,
          styleSheet: MarkdownStyleSheet(
            p: AppFont.body.copyWith(color: color, height: 1.35),
            listIndent: 24,
            blockquote: AppFont.body.copyWith(color: color),
            blockquoteDecoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: color.withValues(alpha: 0.4), width: 4),
              ),
            ),
            code: AppFont.body.copyWith(
              color: color,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            codeblockDecoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            h1: AppFont.h1.copyWith(color: color),
            h2: AppFont.h2.copyWith(color: color),
            h3: AppFont.h3.copyWith(color: color),
            a: TextStyle(color: AppColor.primaryTint, decoration: TextDecoration.underline),
          ),
          shrinkWrap: true,
          fitContent: true,
        );
      }).toList(),
    );
  }
}
