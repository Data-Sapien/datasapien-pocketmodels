import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// Error cases mirror iOS `DocumentParserError`.
enum DocumentParserErrorKind {
  fileNotFound,
  unreadableContent,
  unsupportedFormat,
}

class DocumentParserException implements Exception {
  DocumentParserException(this.kind, [this.message]);
  final DocumentParserErrorKind kind;
  final String? message;

  @override
  String toString() => 'DocumentParserException($kind${message == null ? '' : ': $message'})';
}

/// Extracts plain text from a document path for attachment into chat context.
/// Mirrors `DSAI/Services/DocumentParser.swift` behavior: PDF via PDFKit,
/// TXT/CSV/JSON as UTF-8 with an ASCII fallback, RTF stripped to plain text.
class DocumentParser {
  DocumentParser._();

  static Future<String> extractText(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw DocumentParserException(DocumentParserErrorKind.fileNotFound, path);
    }

    final ext = _extensionOf(path);
    switch (ext) {
      case 'pdf':
        return await compute(_parsePdf, path);
      case 'txt':
      case 'csv':
      case 'json':
      case 'xml':
        return await compute(_parsePlainText, path);
      case 'rtf':
        return await compute(_parseRtf, path);
      default:
        // Attempt plain text as a fallback, matching iOS fallback.
        try {
          return await compute(_parsePlainText, path);
        } catch (_) {
          throw DocumentParserException(
            DocumentParserErrorKind.unsupportedFormat,
            ext,
          );
        }
    }
  }

  static String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot < 0 || dot == path.length - 1) return '';
    return path.substring(dot + 1).toLowerCase();
  }
}

String _parsePdf(String path) {
  final bytes = File(path).readAsBytesSync();
  PdfDocument? document;
  try {
    document = PdfDocument(inputBytes: bytes);
    final extracted = PdfTextExtractor(document).extractText();
    final trimmed = extracted.trim();
    if (trimmed.isEmpty) {
      throw DocumentParserException(DocumentParserErrorKind.unreadableContent);
    }
    return trimmed;
  } on DocumentParserException {
    rethrow;
  } catch (e) {
    throw DocumentParserException(
      DocumentParserErrorKind.unreadableContent,
      e.toString(),
    );
  } finally {
    document?.dispose();
  }
}

String _parsePlainText(String path) {
  final bytes = File(path).readAsBytesSync();
  try {
    return utf8.decode(bytes).trim();
  } catch (_) {
    // Fall back to Latin-1 (closest Dart analogue to iOS .ascii fallback that
    // still decodes high-byte characters without throwing).
    return latin1.decode(bytes).trim();
  }
}

String _parseRtf(String path) {
  final bytes = File(path).readAsBytesSync();
  late final String raw;
  try {
    raw = utf8.decode(bytes);
  } catch (_) {
    raw = latin1.decode(bytes);
  }

  // Best-effort RTF-to-plain-text. Dart has no NSAttributedString, so we strip
  // control words, groups, and escaped characters. This is lossy vs iOS.
  var text = raw;

  // Remove font tables, stylesheets, color tables and similar binary groups.
  final headerGroups = RegExp(
    r'\{\\\*?\\(fonttbl|colortbl|stylesheet|info|pict|object|themedata|latentstyles|datastore)[^{}]*(\{[^{}]*\}[^{}]*)*\}',
    multiLine: true,
  );
  for (var i = 0; i < 4; i++) {
    final next = text.replaceAll(headerGroups, '');
    if (next == text) break;
    text = next;
  }

  // Convert escaped line/paragraph breaks to newlines.
  text = text.replaceAll(RegExp(r"\\par[d]?"), '\n');
  text = text.replaceAll(RegExp(r"\\line"), '\n');
  text = text.replaceAll(RegExp(r"\\tab"), '\t');

  // Hex-escaped bytes (\'xx) -> best-effort Latin-1 character.
  text = text.replaceAllMapped(
    RegExp(r"\\'([0-9a-fA-F]{2})"),
    (m) {
      final byte = int.parse(m.group(1)!, radix: 16);
      try {
        return latin1.decode([byte]);
      } catch (_) {
        return '';
      }
    },
  );

  // Remove remaining control words (\foo123) and control symbols (\*, \\, \{ ...).
  text = text.replaceAll(RegExp(r'\\[a-zA-Z]+-?\d*\s?'), '');
  text = text.replaceAll(RegExp(r'\\[^a-zA-Z]'), '');

  // Strip remaining braces.
  text = text.replaceAll(RegExp(r'[{}]'), '');

  final trimmed = text.trim();
  if (trimmed.isEmpty) {
    // Fall back to raw plain-text read (matches iOS "fallback" philosophy).
    final fallback = _parsePlainText(path);
    if (fallback.isEmpty) {
      throw DocumentParserException(DocumentParserErrorKind.unreadableContent);
    }
    return fallback;
  }
  return trimmed;
}
