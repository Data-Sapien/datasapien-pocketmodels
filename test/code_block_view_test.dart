import 'package:datasapien_pocketmodels/widgets/chat/code_block_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CodeBlockView builds for dart and unknown fence language', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CodeBlockView(
            code: 'void main() {\n  print("hi");\n}',
            language: 'dart',
          ),
        ),
      ),
    );
    expect(find.byType(CodeBlockView), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CodeBlockView(
            code: 'plain text',
            language: 'not-a-real-lang',
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
