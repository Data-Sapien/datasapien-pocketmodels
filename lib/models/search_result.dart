/// Web search result; mirrors iOS WebSearchService.SearchResult.
class SearchResult {
  const SearchResult({
    required this.title,
    required this.url,
    required this.snippet,
  });

  final String title;
  final String url;
  final String snippet;
}
