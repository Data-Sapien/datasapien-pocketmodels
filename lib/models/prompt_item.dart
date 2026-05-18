/// Model for AI personalization prompt profile (preset or custom).
/// Mirrors iOS PromptItem; stored as JSON for custom prompts.
class PromptItem {
  const PromptItem({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.isPreset,
    required this.icon,
  });

  final String id;
  final String title;
  final String description;
  final String content;
  final bool isPreset;
  final String icon;

  PromptItem copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    bool? isPreset,
    String? icon,
  }) {
    return PromptItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      isPreset: isPreset ?? this.isPreset,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'content': content,
        'isPreset': isPreset,
        'icon': icon,
      };

  static PromptItem fromJson(Map<String, dynamic> json) {
    return PromptItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      content: json['content'] as String? ?? '',
      isPreset: json['isPreset'] as bool? ?? false,
      icon: json['icon'] as String? ?? 'edit',
    );
  }
}
