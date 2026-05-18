/// Persisted message row; mirrors iOS ChatStoredMessage.
/// Used for DB storage only; HistoryManager hydrates to ChatMessage when loading.
class ChatStoredMessage {
  const ChatStoredMessage({
    required this.id,
    required this.roleText,
    required this.text,
    required this.timestamp,
    required this.sessionId,
  });

  final String id;
  final String roleText; // e.g. "user", "ai", "journey", "document", "webSearch"
  final String text;
  final DateTime timestamp;
  final String sessionId;

  Map<String, Object?> toRow() => {
        'id': id,
        'session_id': sessionId,
        'role_text': roleText,
        'text': text,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  static ChatStoredMessage fromRow(Map<String, Object?> row) {
    return ChatStoredMessage(
      id: row['id'] as String,
      sessionId: row['session_id'] as String,
      roleText: row['role_text'] as String,
      text: row['text'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    );
  }
}
