import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../models/chat_stored_message.dart';

/// Persisted chat sessions and messages via sqflite; notifies listeners on change.
class HistoryManager extends ChangeNotifier {
  HistoryManager._();
  static final HistoryManager instance = HistoryManager._();

  static const String _dbName = 'chat_history.db';
  static const int _dbVersion = 1;

  Database? _db;
  final Completer<void> _initCompleter = Completer<void>();

  Future<Database> get _database async {
    if (_db != null) return _db!;
    if (!_initCompleter.isCompleted) {
      _db = await _openDatabase();
      _initCompleter.complete();
    }
    return _db!;
  }

  Future<Database> _openDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chat_sessions (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE chat_stored_messages (
            id TEXT PRIMARY KEY,
            session_id TEXT NOT NULL,
            role_text TEXT NOT NULL,
            text TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_messages_session ON chat_stored_messages(session_id)',
        );
      },
    );
  }

  /// Call once at app start so that _database is available.
  Future<void> ensureInitialized() async {
    await _database;
  }

  /// All sessions, newest first.
  Future<List<ChatSession>> fetchAllSessions() async {
    final db = await _database;
    final rows = await db.query(
      'chat_sessions',
      orderBy: 'updated_at DESC',
    );
    return rows.map(_sessionFromRow).toList();
  }

  /// Session IDs with at least one message containing [query], case-insensitive.
  Future<Set<String>> searchSessionIdsByMessageText(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return <String>{};
    final db = await _database;
    final rows = await db.rawQuery(
      '''
      SELECT DISTINCT session_id
      FROM chat_stored_messages
      WHERE LOWER(text) LIKE ?
      ''',
      ['%$normalized%'],
    );
    return rows
        .map((row) => row['session_id'])
        .whereType<String>()
        .toSet();
  }

  static ChatSession _sessionFromRow(Map<String, Object?> row) {
    return ChatSession(
      id: row['id'] as String,
      title: row['title'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
    );
  }

  /// Create a new session.
  Future<ChatSession> createSession() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    final session = ChatSession(
      id: id,
      title: 'New chat',
      createdAt: now,
      updatedAt: now,
    );
    final db = await _database;
    await db.insert('chat_sessions', {
      'id': session.id,
      'title': session.title,
      'created_at': session.createdAt.millisecondsSinceEpoch,
      'updated_at': session.updatedAt.millisecondsSinceEpoch,
    });
    notifyListeners();
    return session;
  }

  static String _roleTextFromType(ChatMessageType type) {
    return switch (type) {
      UserMessageType() => 'user',
      AiMessageType() => 'ai',
      JourneyMessageType() => 'journey',
      MemoryUpdateMessageType() => 'memoryUpdate',
      ImageMessageType() => 'image',
      DocumentMessageType(name: _) => 'document',
      WebSearchMessageType(query: _) => 'webSearch',
    };
  }

  /// For document we store "name\ncontent" in text; for webSearch we store query in text.
  static String _storageTextForMessage(ChatMessage message) {
    final type = message.type;
    if (type is DocumentMessageType) {
      return '${type.name}\n${message.text}';
    }
    if (type is ImageMessageType) {
      return type.path;
    }
    if (type is WebSearchMessageType) {
      return type.query;
    }
    return message.text;
  }

  static ChatMessageType _typeFromRoleText(String roleText, String text) {
    return switch (roleText) {
      'user' => const UserMessageType(),
      'ai' => const AiMessageType(),
      'journey' => const JourneyMessageType(),
      'memoryUpdate' => const MemoryUpdateMessageType(),
      'image' => ImageMessageType(text),
      'document' => DocumentMessageType(_documentNameFromStorageText(text)),
      'webSearch' => WebSearchMessageType(text),
      _ => const AiMessageType(),
    };
  }

  static String _documentNameFromStorageText(String storageText) {
    final idx = storageText.indexOf('\n');
    return idx >= 0 ? storageText.substring(0, idx) : storageText;
  }

  static String _documentContentFromStorageText(String storageText) {
    final idx = storageText.indexOf('\n');
    return idx >= 0 ? storageText.substring(idx + 1) : '';
  }

  /// Append a message to a session; updates session.updatedAt and title from first user message.
  Future<void> saveMessage(String sessionId, ChatMessage message) async {
    final db = await _database;
    final roleText = _roleTextFromType(message.type);
    final storageText = _storageTextForMessage(message);
    final stored = ChatStoredMessage(
      id: message.id,
      sessionId: sessionId,
      roleText: roleText,
      text: storageText,
      timestamp: message.timestamp,
    );
    await db.insert('chat_stored_messages', stored.toRow());

    final sessions = await db.query(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    if (sessions.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    String? newTitle;
    if (roleText == 'user') {
      final count = await db.query(
        'chat_stored_messages',
        columns: ['id'],
        where: 'session_id = ? AND role_text = ?',
        whereArgs: [sessionId, 'user'],
      );
      if (count.length == 1) {
        final preview = message.text.trim().replaceAll(RegExp(r'\s+'), ' ');
        newTitle = preview.length > 30
            ? '${preview.substring(0, 30)}...'
            : (preview.isEmpty ? 'New chat' : preview);
      }
    }
    await db.update(
      'chat_sessions',
      {
        'updated_at': now,
        if (newTitle != null) 'title': newTitle,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    notifyListeners();
  }

  /// Messages for a session (for main chat when opening from history).
  Future<List<ChatMessage>> getMessagesForSession(String sessionId) async {
    final db = await _database;
    final rows = await db.query(
      'chat_stored_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'timestamp ASC',
    );
    return rows.map((row) {
      final stored = ChatStoredMessage.fromRow(row);
      final type = _typeFromRoleText(stored.roleText, stored.text);
      String text = stored.text;
      if (stored.roleText == 'document') {
        text = _documentContentFromStorageText(stored.text);
      }
      return ChatMessage(
        id: stored.id,
        type: type,
        text: text,
        timestamp: stored.timestamp,
      );
    }).toList();
  }

  /// Remove a session and its messages.
  Future<void> deleteSession(ChatSession session) async {
    final db = await _database;
    await db.delete(
      'chat_stored_messages',
      where: 'session_id = ?',
      whereArgs: [session.id],
    );
    await db.delete(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [session.id],
    );
    notifyListeners();
  }

  /// Delete all sessions and their messages.
  Future<void> deleteAllSessions() async {
    final db = await _database;
    await db.delete('chat_stored_messages');
    await db.delete('chat_sessions');
    notifyListeners();
  }
}
