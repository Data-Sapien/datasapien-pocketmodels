import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:intl/intl.dart';

/// One row in the My Data profile list (mirrors iOS [InferredRecordItem]).
class MeDataProfileRow {
  const MeDataProfileRow({
    required this.definitionName,
    required this.displayName,
    required this.displayValue,
    required this.isNative,
    required this.valueType,
    required this.allRecords,
  });

  final String definitionName;
  final String displayName;
  final String displayValue;
  final bool isNative;
  final DataType? valueType;
  final List<MeDataRecord> allRecords;
}

/// Section header + rows (mirrors iOS [CategorySection]).
class MeDataProfileSection {
  const MeDataProfileSection({
    required this.categoryName,
    required this.items,
  });

  final String categoryName;
  final List<MeDataProfileRow> items;
}

/// Loads My Data grouped by category using the same rules as iOS
/// [MyDataViewController] (no [getMeDataCategoryGroups] on Flutter — composed
/// from categories + definitions + records).
class MeDataCategoryLoader {
  MeDataCategoryLoader._();

  /// Formats a stored value string as localized date/time when [type] is datetime
  /// (matches iOS [MyDataViewController.formatDateString]).
  static String formatDisplayValue(String combinedValues, DataType? type) {
    if (type != DataType.datetime) return combinedValues;
    return _formatEpochString(combinedValues);
  }

  static String _formatEpochString(String value) {
    final epoch = double.tryParse(value.trim());
    if (epoch == null) return value;
    final ms = epoch > 1e12 ? epoch : epoch * 1000;
    final date = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: false);
    return DateFormat.yMMMd().add_jm().format(date);
  }

  /// Formats record values for display (list row or history cell).
  static String combinedValuesForRecord(
    MeDataRecord record,
    DataType? type,
  ) {
    final raw = record.values.map((v) => v.value).join(', ');
    return formatDisplayValue(raw, type);
  }

  static int _compareDateDesc(MeDataRecord a, MeDataRecord b) {
    final ad = a.date.toDouble();
    final bd = b.date.toDouble();
    if (ad > bd) return -1;
    if (ad < bd) return 1;
    return 0;
  }

  /// Loads sections sorted by category display name.
  static Future<List<MeDataProfileSection>> loadProfileSections(
    MeDataService meDataService,
  ) async {
    var categories = await meDataService.getMeDataCategories();
    if (categories == null || categories.isEmpty) {
      return _loadFromDefinitionsFallback(meDataService);
    }

    final sections = <MeDataProfileSection>[];
    for (final cat in categories) {
      final defs =
          await meDataService.getMeDataDefinitionsByCategory(cat.name);
      if (defs == null || defs.isEmpty) continue;

      final items = <MeDataProfileRow>[];
      for (final def in defs) {
        if (def.hidden == true) continue;
        final records = await meDataService.getMeDataRecords(def.name);
        if (records == null || records.isEmpty) continue;

        final sorted = List<MeDataRecord>.from(records)..sort(_compareDateDesc);
        final latest = sorted.first;
        var combinedValues =
            latest.values.map((v) => v.value).join(', ');
        final vType = def.valueDef?.type;
        combinedValues = formatDisplayValue(combinedValues, vType);
        if (combinedValues.isEmpty) continue;

        items.add(
          MeDataProfileRow(
            definitionName: def.name,
            displayName: def.text,
            displayValue: combinedValues,
            isNative: def.source.toLowerCase() == 'native',
            valueType: vType,
            allRecords: records,
          ),
        );
      }

      if (items.isNotEmpty) {
        sections.add(
          MeDataProfileSection(categoryName: cat.text, items: items),
        );
      }
    }

    sections.sort(
      (a, b) => a.categoryName.toLowerCase().compareTo(
            b.categoryName.toLowerCase(),
          ),
    );
    return sections;
  }

  static Future<List<MeDataProfileSection>> _loadFromDefinitionsFallback(
    MeDataService meDataService,
  ) async {
    final allDefs = await meDataService.getMeDataDefinitions();
    final byCategory = <String, List<MeDataDefinition>>{};
    for (final def in allDefs) {
      if (def.hidden == true) continue;
      final key = def.category?.text ?? '';
      byCategory.putIfAbsent(key, () => []).add(def);
    }

    final sections = <MeDataProfileSection>[];
    for (final entry in byCategory.entries) {
      final categoryName = entry.key.isEmpty ? 'Other' : entry.key;
      final items = <MeDataProfileRow>[];

      for (final def in entry.value) {
        final records = await meDataService.getMeDataRecords(def.name);
        if (records == null || records.isEmpty) continue;

        final sorted = List<MeDataRecord>.from(records)..sort(_compareDateDesc);
        final latest = sorted.first;
        var combinedValues =
            latest.values.map((v) => v.value).join(', ');
        final vType = def.valueDef?.type;
        combinedValues = formatDisplayValue(combinedValues, vType);
        if (combinedValues.isEmpty) continue;

        items.add(
          MeDataProfileRow(
            definitionName: def.name,
            displayName: def.text,
            displayValue: combinedValues,
            isNative: def.source.toLowerCase() == 'native',
            valueType: vType,
            allRecords: records,
          ),
        );
      }

      if (items.isNotEmpty) {
        sections.add(
          MeDataProfileSection(categoryName: categoryName, items: items),
        );
      }
    }

    sections.sort(
      (a, b) => a.categoryName.toLowerCase().compareTo(
            b.categoryName.toLowerCase(),
          ),
    );
    return sections;
  }

  /// Builds LLM context like iOS [MainChatViewModel.formatCategoryGroupsToText].
  static String formatSectionsForPrompt(List<MeDataProfileSection> sections) {
    if (sections.isEmpty) return '';
    final buf = StringBuffer();
    for (final sec in sections) {
      final lines = <String>[];
      for (final row in sec.items) {
        final sorted = List<MeDataRecord>.from(row.allRecords)
          ..sort(_compareDateDesc);
        if (sorted.isEmpty) continue;
        final latest = sorted.first;
        final values = latest.values.map((v) => v.value).join(', ');
        if (values.isEmpty) continue;
        lines.add('- ${row.displayName}: $values');
      }
      if (lines.isNotEmpty) {
        buf.writeln();
        buf.writeln('[${sec.categoryName}]');
        for (final line in lines) {
          buf.writeln(line);
        }
      }
    }
    return buf.toString().trim();
  }
}
