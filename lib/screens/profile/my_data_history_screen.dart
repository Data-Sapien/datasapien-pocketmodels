import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../services/me_data_category_loader.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';

/// Per-definition history (mirrors iOS [MyDataDetailViewController]).
class MyDataHistoryScreen extends StatefulWidget {
  const MyDataHistoryScreen({
    super.key,
    required this.definitionName,
    required this.definitionDisplayName,
    required this.valueType,
    required this.records,
    required this.isNative,
  });

  final String definitionName;
  final String definitionDisplayName;
  final DataType? valueType;
  final List<MeDataRecord> records;
  final bool isNative;

  @override
  State<MyDataHistoryScreen> createState() => _MyDataHistoryScreenState();
}

class _MyDataHistoryScreenState extends State<MyDataHistoryScreen> {
  late final List<MeDataRecord> _records;

  List<MeDataRecord> get _sorted {
    final list = List<MeDataRecord>.from(_records)
      ..sort((a, b) {
        final ad = a.date.toDouble();
        final bd = b.date.toDouble();
        if (ad > bd) return -1;
        if (ad < bd) return 1;
        return 0;
      });
    return list;
  }

  static String _formatRecordDate(num date) {
    var ms = date.toDouble();
    if (ms < 1e12) ms *= 1000;
    final dt = DateTime.fromMillisecondsSinceEpoch(ms.toInt(), isUtc: false);
    return DateFormat.yMMMd().add_jm().format(dt);
  }

  @override
  void initState() {
    super.initState();
    _records = List<MeDataRecord>.from(widget.records);
  }

  Future<bool> _deleteRecord(MeDataRecord record) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await DataSapien.getMeDataService().deleteMeDataRecord(
        widget.definitionName,
        record.id,
      );
      try {
        await DataSapien.getJourneyService().syncJourneys();
      } catch (_) {}
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.my_data_delete_failed)),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sorted = _sorted;

    return Scaffold(
      backgroundColor: AppColor.secondaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColor.secondaryBackground(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.profile_my_data_history_title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColor.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Text(
            widget.definitionDisplayName.toUpperCase(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColor.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          if (sorted.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l10n.no_inferred_data,
                style: AppFont.body.copyWith(
                  color: AppColor.textSecondary(context),
                ),
              ),
            ),
          ...sorted.map(
            (record) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: widget.isNative
                  ? _HistoryRecordCard(
                      dateText: _formatRecordDate(record.date),
                      valueText: MeDataCategoryLoader.combinedValuesForRecord(
                        record,
                        widget.valueType,
                      ),
                    )
                  : Dismissible(
                      key: ValueKey(
                        '${widget.definitionName}_${record.id}_${record.date}',
                      ),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => _deleteRecord(record),
                      onDismissed: (_) {
                        setState(() {
                          _records.removeWhere((r) => r.id == record.id);
                        });
                      },
                      child: _HistoryRecordCard(
                        dateText: _formatRecordDate(record.date),
                        valueText: MeDataCategoryLoader.combinedValuesForRecord(
                          record,
                          widget.valueType,
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRecordCard extends StatelessWidget {
  const _HistoryRecordCard({
    required this.dateText,
    required this.valueText,
  });

  final String dateText;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.primaryBackground(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateText,
              style: AppFont.captionBold.copyWith(color: AppColor.primaryTint),
            ),
            const SizedBox(height: 4),
            Text(
              valueText,
              style:
                  AppFont.body.copyWith(color: AppColor.textPrimary(context)),
            ),
          ],
        ),
      ),
    );
  }
}
