import 'app_constants.dart';

/// Resolves managed-model image paths the same way iOS `DSURLHelper.getFullImageUrl` does.
Uri? resolveManagedModelImageUrl(String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return null;
  final trimmed = imageUrl.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return Uri.tryParse(trimmed);
  }
  final base = AppConstants.mediaBaseUrl.endsWith('/')
      ? AppConstants.mediaBaseUrl
      : '${AppConstants.mediaBaseUrl}/';
  final path = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
  return Uri.tryParse('$base$path');
}
