import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

import '../../theme/app_icons.dart';
import 'code_syntax_highlighter.dart';

/// Code block with optional language label and copy button; mirrors iOS CodeBlockView.
class CodeBlockView extends StatefulWidget {
  const CodeBlockView({
    super.key,
    required this.code,
    this.language,
  });

  final String code;
  final String? language;

  @override
  State<CodeBlockView> createState() => _CodeBlockViewState();
}

class _CodeBlockViewState extends State<CodeBlockView> {
  bool _copied = false;

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageLabel =
        (widget.language?.toLowerCase().isNotEmpty == true ? widget.language! : 'code')
            .split(RegExp(r'[\s+]'))
            .first
            .trim();
    final displayLang = languageLabel.isEmpty ? 'Code' : '${languageLabel[0].toUpperCase()}${languageLabel.length > 1 ? languageLabel.substring(1) : ''}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: const Color(0xFF262626),
            child: Row(
              children: [
                Text(
                  displayLang,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                    color: Color(0xFFB3B3B3),
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _copied ? null : _copyToClipboard,
                  icon: Icon(
                    _copied ? AppIcons.checkmark : AppIcons.documentOnDocument,
                    size: 12,
                    color: _copied ? Colors.green : const Color(0xFFB3B3B3),
                  ),
                  label: Text(
                    _copied ? 'Copied!' : 'Copy',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB3B3B3),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: HighlightView(
                widget.code,
                language: highlightLanguageForFence(widget.language),
                theme: codeBlockHighlightTheme,
                padding: EdgeInsets.zero,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
