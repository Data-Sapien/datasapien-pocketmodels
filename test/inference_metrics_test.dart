import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:datasapien_pocketmodels/utils/inference_metrics.dart';

void main() {
  group('approxPromptTokenCount', () {
    test('empty prompts yields 1', () {
      expect(approxPromptTokenCount([]), 1);
    });

    test('matches whitespace word heuristic', () {
      expect(
        approxPromptTokenCount([
          Prompt(role: PromptRole.user, content: 'hello   world'),
        ]),
        2,
      );
    });
  });

  group('performanceFromStreamStats', () {
    test('zero chunks yields 0 t/s and prompt-only usedTokens', () {
      final t0 = DateTime(2026, 1, 1, 12);
      final perf = performanceFromStreamStats(
        generatedChunkCount: 0,
        firstChunkTime: null,
        completedTime: t0,
        prompts: [
          Prompt(role: PromptRole.user, content: 'a b'),
        ],
        nCtx: 10000,
      );
      expect(perf.tokensPerSecond, 0.0);
      expect(perf.usedTokens, 2);
      expect(perf.maxTokens, 10000);
    });

    test('tps from first chunk to completedTime', () {
      final first = DateTime(2026, 1, 1, 12);
      final end = first.add(const Duration(seconds: 2));
      final perf = performanceFromStreamStats(
        generatedChunkCount: 10,
        firstChunkTime: first,
        completedTime: end,
        prompts: [
          Prompt(role: PromptRole.system, content: 'x'),
        ],
        nCtx: 4096,
      );
      expect(perf.tokensPerSecond, closeTo(5.0, 0.001));
      expect(perf.usedTokens, 11);
    });
  });
}
