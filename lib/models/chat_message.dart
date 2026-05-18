import 'message_performance.dart';
import 'search_result.dart';

/// Message type discriminator; mirrors iOS ChatMessageType.
sealed class ChatMessageType {
  const ChatMessageType();
}

class UserMessageType extends ChatMessageType {
  const UserMessageType();
}

class AiMessageType extends ChatMessageType {
  const AiMessageType();
}

class JourneyMessageType extends ChatMessageType {
  const JourneyMessageType();
}

class MemoryUpdateMessageType extends ChatMessageType {
  const MemoryUpdateMessageType();
}

class ImageMessageType extends ChatMessageType {
  const ImageMessageType(this.path);
  final String path;
}

class DocumentMessageType extends ChatMessageType {
  const DocumentMessageType(this.name);
  final String name;
}

class WebSearchMessageType extends ChatMessageType {
  const WebSearchMessageType(this.query, [this.results]);
  final String query;
  final List<SearchResult>? results;
}

/// Chat message model; mirrors iOS ChatMessage.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.type,
    required this.text,
    DateTime? timestamp,
    this.isStreaming = false,
    this.isError = false,
    this.metrics,
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;
  final ChatMessageType type;
  String text;
  final DateTime timestamp;
  bool isStreaming;
  bool isError;
  MessagePerformance? metrics;
}
