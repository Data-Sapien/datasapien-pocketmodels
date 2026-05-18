import 'dart:convert';
import 'dart:math';

import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:http/http.dart' as http;

class HuggingFaceModelSummary {
  const HuggingFaceModelSummary({
    required this.id,
    required this.downloads,
    required this.likes,
  });

  final String id;
  final int downloads;
  final int likes;
}

class HuggingFaceModelFile {
  const HuggingFaceModelFile({
    required this.path,
    required this.sizeBytes,
  });

  final String path;
  final int sizeBytes;
}

/// One page of Hub search results after client-side GGUF filtering.
class HuggingFaceSearchPage {
  const HuggingFaceSearchPage({
    required this.models,
    required this.rawResultCount,
    this.failed = false,
  });

  final List<HuggingFaceModelSummary> models;
  /// Raw items returned by the API (before `.gguf` sibling filter); use for pagination offset.
  final int rawResultCount;
  final bool failed;
}

class HuggingFaceGgufListResult {
  const HuggingFaceGgufListResult({
    required this.files,
    this.requestFailed = false,
  });

  final List<HuggingFaceModelFile> files;
  final bool requestFailed;
}

class HuggingFaceService {
  HuggingFaceService._();
  static final HuggingFaceService instance = HuggingFaceService._();

  static const String _baseUrl = 'https://huggingface.co/api/models';

  /// Matches iOS `GGUFFilePickerViewController` — used for managed model list artwork.
  static const String huggingFaceBadgeImageUrl =
      'https://huggingface.co/front/assets/huggingface_logo-noborder.svg';

  /// Android DSSDK requires `saveManagedAIModel` id to parse as [UUID].
  static String _newUuidV4() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
  }

  Future<HuggingFaceSearchPage> searchModels(
    String query, {
    int offset = 0,
    int limit = 20,
  }) async {
    final encodedQuery = Uri.encodeQueryComponent(query);
    final uri = Uri.parse(
      '$_baseUrl?filter=gguf&search=$encodedQuery&sort=downloads&direction=-1&limit=$limit&offset=$offset&full=true',
    );
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return const HuggingFaceSearchPage(models: [], rawResultCount: 0, failed: true);
      }
      final raw = jsonDecode(response.body);
      if (raw is! List) {
        return const HuggingFaceSearchPage(models: [], rawResultCount: 0, failed: true);
      }

      final results = <HuggingFaceModelSummary>[];
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        final siblings = item['siblings'];
        final hasGguf = siblings is List &&
            siblings.any(
              (entry) =>
                  entry is Map<String, dynamic> &&
                  (entry['rfilename'] as String?)?.toLowerCase().endsWith('.gguf') == true,
            );
        if (!hasGguf) continue;
        final id = item['id'] as String?;
        if (id == null || id.isEmpty) continue;
        results.add(
          HuggingFaceModelSummary(
            id: id,
            downloads: (item['downloads'] as num?)?.toInt() ?? 0,
            likes: (item['likes'] as num?)?.toInt() ?? 0,
          ),
        );
      }
      return HuggingFaceSearchPage(
        models: results,
        rawResultCount: raw.length,
        failed: false,
      );
    } catch (_) {
      return const HuggingFaceSearchPage(models: [], rawResultCount: 0, failed: true);
    }
  }

  Future<HuggingFaceGgufListResult> fetchGgufFiles(String modelId) async {
    final encodedId = Uri.encodeComponent(modelId).replaceAll('%2F', '/');
    final uri = Uri.parse('$_baseUrl/$encodedId/tree/main');
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return const HuggingFaceGgufListResult(files: [], requestFailed: true);
      }
      final raw = jsonDecode(response.body);
      if (raw is! List) {
        return const HuggingFaceGgufListResult(files: [], requestFailed: true);
      }

      final files = <HuggingFaceModelFile>[];
      for (final item in raw) {
        if (item is! Map<String, dynamic>) continue;
        if (item['type'] != 'file') continue;
        final path = item['path'] as String?;
        if (path == null || !path.toLowerCase().endsWith('.gguf')) continue;
        final lfs = item['lfs'] as Map<String, dynamic>?;
        final size = (lfs?['size'] as num?)?.toInt() ?? (item['size'] as num?)?.toInt() ?? 0;
        files.add(HuggingFaceModelFile(path: path, sizeBytes: size));
      }
      files.sort((a, b) => a.sizeBytes.compareTo(b.sizeBytes));
      return HuggingFaceGgufListResult(files: files, requestFailed: false);
    } catch (_) {
      return const HuggingFaceGgufListResult(files: [], requestFailed: true);
    }
  }

  /// Compact display for download/like counts (matches iOS `abbreviatedCount`).
  static String abbreviatedCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  /// Registers the GGUF with the native SDK (same as iOS `saveManagedAIModel`).
  /// Download happens later from the model selector via [downloadModelFiles].
  Future<void> addManagedModel({
    required String modelId,
    required HuggingFaceModelFile file,
  }) async {
    final nameWithoutExt = file.path.replaceAll(RegExp(r'\.gguf$', caseSensitive: false), '');
    final modelName = nameWithoutExt.replaceAll(' ', '_');
    final displayText = nameWithoutExt
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .trim();
    final downloadUrl =
        'https://huggingface.co/$modelId/resolve/main/${Uri.encodeComponent(file.path).replaceAll('%2F', '/')}?download=true';
    final sizeDescription = 'Size: ${_formatSize(file.sizeBytes)}';

    final sdkRecordId = _newUuidV4();
    final intelligence = DataSapien.getIntelligenceService();
    await intelligence.saveManagedAIModel(
      sdkRecordId,
      name: modelName,
      text: displayText,
      modelDescription: sizeDescription,
      downloadUrl: downloadUrl,
      imageUrl: huggingFaceBadgeImageUrl,
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return 'Unknown';
    final gb = bytes / 1073741824;
    if (gb >= 1) return '${gb.toStringAsFixed(1)} GB';
    final mb = bytes / 1048576;
    return '${mb.toStringAsFixed(0)} MB';
  }
}
