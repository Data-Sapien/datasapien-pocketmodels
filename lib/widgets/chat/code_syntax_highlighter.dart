import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

/// Atom One Dark with a transparent root so the block matches [CodeBlockView] chrome (#1A1A1A).
final Map<String, TextStyle> codeBlockHighlightTheme = () {
  final m = Map<String, TextStyle>.from(atomOneDarkTheme);
  final root = m['root']!;
  m['root'] = root.copyWith(
    backgroundColor: Colors.transparent,
    fontSize: 13,
  );
  return m;
}();

/// Maps markdown fence language hints to highlight.js ids (see `highlight` package `all.dart`).
String highlightLanguageForFence(String? fenceLanguage) {
  var raw = fenceLanguage?.trim().toLowerCase() ?? '';
  if (raw.isEmpty) return 'plaintext';
  if (raw.startsWith('language-')) {
    raw = raw.substring('language-'.length);
  }
  raw = raw.split(RegExp(r'[\s+]')).first;
  if (raw.isEmpty) return 'plaintext';

  // highlight registers many aliases; a few common fence tags need explicit mapping.
  const overrides = <String, String>{
    'tsx': 'typescript',
  };
  return overrides[raw] ?? raw;
}
