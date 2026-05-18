import 'package:datasapien_sdk/datasapien_sdk.dart';

import '../models/message_performance.dart';

/// Mirrors iOS [InferenceUseCase] approx token heuristic for prompt size.
int approxPromptTokenCount(List<Prompt> prompts) {
  final joined = prompts.map((p) => p.content).join(' ');
  final count = joined
      .split(RegExp(r'\s+'))
      .where((s) => s.isNotEmpty)
      .length;
  return count < 1 ? 1 : count;
}

/// Builds [MessagePerformance] from stream stats (one [onStream] call ≈ one token).
/// Uses generation interval from first chunk to [completedTime], matching iOS DSSDK.
MessagePerformance performanceFromStreamStats({
  required int generatedChunkCount,
  required DateTime? firstChunkTime,
  required DateTime completedTime,
  required List<Prompt> prompts,
  required int nCtx,
}) {
  final promptTok = approxPromptTokenCount(prompts);
  final usedTokens = promptTok + generatedChunkCount;
  var tokensPerSecond = 0.0;
  if (firstChunkTime != null &&
      generatedChunkCount > 0 &&
      !completedTime.isBefore(firstChunkTime)) {
    final genSecs =
        completedTime.difference(firstChunkTime).inMicroseconds / 1e6;
    if (genSecs > 0) {
      tokensPerSecond = generatedChunkCount / genSecs;
    }
  }
  return MessagePerformance(
    tokensPerSecond: tokensPerSecond,
    usedTokens: usedTokens,
    maxTokens: nCtx,
  );
}
