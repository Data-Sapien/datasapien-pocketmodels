/// Minimal journey item for JourneyListCell; can be replaced by SDK type later.
class JourneyListItem {
  const JourneyListItem({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  final String title;
  final String description;
  final String? imageUrl;
}
