import 'package:datasapien_pocketmodels/widgets/chat/code_syntax_highlighter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('highlightLanguageForFence', () {
    test('empty and null map to plaintext', () {
      expect(highlightLanguageForFence(null), 'plaintext');
      expect(highlightLanguageForFence(''), 'plaintext');
      expect(highlightLanguageForFence('   '), 'plaintext');
    });

    test('strips language- prefix', () {
      expect(highlightLanguageForFence('language-dart'), 'dart');
    });

    test('tsx maps to typescript', () {
      expect(highlightLanguageForFence('tsx'), 'typescript');
    });

    test('passes through known ids', () {
      expect(highlightLanguageForFence('swift'), 'swift');
      expect(highlightLanguageForFence('JSON'), 'json');
    });
  });
}
