import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../models/search_result.dart';

/// Performs web search via DuckDuckGo HTML and returns results for chat UI.
class WebSearchService {
  WebSearchService._();
  static final WebSearchService instance = WebSearchService._();

  static const String _ddgHtmlUrl = 'https://html.duckduckgo.com/html/';
  static const Map<String, String> _headers = {
    'User-Agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  };

  /// Performs a DuckDuckGo HTML search and returns top results.
  Future<List<SearchResult>> performSearch(
    String query, {
    int maxResults = 3,
  }) async {
    final encoded = Uri.encodeQueryComponent(query);
    final uri = Uri.parse('$_ddgHtmlUrl?q=$encoded');
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      return [];
    }
    return _parseDuckDuckGoResults(response.body, maxResults: maxResults);
  }

  List<SearchResult> _parseDuckDuckGoResults(String html,
      {int maxResults = 3}) {
    final document = html_parser.parse(html);
    final results = <SearchResult>[];
    final resultElements = document.querySelectorAll('.result');

    for (final element in resultElements) {
      if (results.length >= maxResults) break;
      try {
        final titleEl = element.querySelector('.result__title .result__a');
        final title = titleEl?.text.trim() ?? '';
        var url = titleEl?.attributes['href'] ?? '';
        if (url.contains('uddg=')) {
          final uri = Uri.tryParse(url);
          final uddg = uri?.queryParameters['uddg'];
          if (uddg != null) url = uddg;
        } else if (url.startsWith('//')) {
          url = 'https:$url';
        }
        final snippetEl = element.querySelector('.result__snippet');
        final snippet = snippetEl?.text.trim() ?? '';
        if (title.isNotEmpty && url.isNotEmpty && url.startsWith('http')) {
          results.add(SearchResult(title: title, url: url, snippet: snippet));
        }
      } catch (_) {}
    }
    return results;
  }

  /// Fetches a web page and extracts plain-text chunks for RAG context.
  Future<List<String>> extractContent(
    String url, {
    int maxChunks = 1,
    int chunkLength = 600,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return [];
    final response = await http.get(uri, headers: _headers);
    if (response.statusCode != 200) return [];

    final document = html_parser.parse(response.body);
    final text = document.body?.text ?? '';
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return [];

    final chunks = <String>[];
    var cursor = 0;
    while (cursor < normalized.length && chunks.length < maxChunks) {
      final end = (cursor + chunkLength).clamp(0, normalized.length);
      chunks.add(normalized.substring(cursor, end));
      cursor = end;
    }
    return chunks;
  }
}
