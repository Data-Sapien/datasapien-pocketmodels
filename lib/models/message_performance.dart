/// AI message performance metrics; mirrors iOS MessagePerformance.
class MessagePerformance {
  const MessagePerformance({
    required this.tokensPerSecond,
    required this.usedTokens,
    required this.maxTokens,
  });

  final double tokensPerSecond;
  final int usedTokens;
  final int maxTokens;
}
