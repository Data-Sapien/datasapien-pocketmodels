/// Chat session model; mirrors iOS ChatSession.
/// Used for the history list; messages are loaded via HistoryManager.getMessagesForSession.
class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
}
