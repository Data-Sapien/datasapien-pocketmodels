import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/me_data_category_loader.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../widgets/profile/my_data_row.dart';
import 'my_data_history_screen.dart';

/// My Data tab: category sections from [MeDataCategoryLoader] (iOS parity).
class MyDataTab extends StatefulWidget {
  const MyDataTab({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  State<MyDataTab> createState() => _MyDataTabState();
}

class _MyDataTabState extends State<MyDataTab> {
  List<MeDataProfileSection> _sections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({bool showLoading = true}) async {
    if (!mounted) return;
    if (showLoading) {
      setState(() => _loading = true);
    }
    try {
      final meDataService = DataSapien.getMeDataService();
      final sections =
          await MeDataCategoryLoader.loadProfileSections(meDataService);
      if (!mounted) return;
      setState(() {
        _sections = sections;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sections = [];
        _loading = false;
      });
    }
  }

  Future<bool> _confirmDelete(MeDataProfileRow row) async {
    try {
      await DataSapien.getMeDataService().deleteMeData(row.definitionName);
      try {
        await DataSapien.getJourneyService().syncJourneys();
      } catch (_) {}
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.my_data_delete_failed),
          ),
        );
      }
      return false;
    }
  }

  void _removeRowFromState(MeDataProfileRow row) {
    if (!mounted) return;
    setState(() {
      _sections = _sections
          .map((sec) {
            final items = sec.items
                .where((r) => r.definitionName != row.definitionName)
                .toList();
            return MeDataProfileSection(
              categoryName: sec.categoryName,
              items: items,
            );
          })
          .where((sec) => sec.items.isNotEmpty)
          .toList();
    });
  }

  Future<void> _openHistory(MeDataProfileRow row) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => MyDataHistoryScreen(
          definitionName: row.definitionName,
          definitionDisplayName: row.displayName,
          valueType: row.valueType,
          records: row.allRecords,
          isNative: row.isNative,
        ),
      ),
    );
    if (!mounted) return;
    await _fetchData(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return ColoredBox(
        color: AppColor.secondaryBackground(context),
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_sections.isEmpty) {
      return ColoredBox(
        color: AppColor.secondaryBackground(context),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppLocalizations.of(context)!.no_inferred_data,
              textAlign: TextAlign.center,
              style: AppFont.body.copyWith(
                color: AppColor.textSecondary(context),
              ),
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: AppColor.secondaryBackground(context),
      child: RefreshIndicator(
        onRefresh: () => _fetchData(showLoading: false),
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            for (final sec in _sections) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text(
                  sec.categoryName,
                  style: AppFont.captionBold.copyWith(
                    color: AppColor.textSecondary(context),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColor.primaryBackground(context),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < sec.items.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColor.textSecondary(context)
                                  .withValues(alpha: 0.12),
                            ),
                          _buildRowTile(context, sec, sec.items[i]),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRowTile(
    BuildContext context,
    MeDataProfileSection sec,
    MeDataProfileRow row,
  ) {
    final tile = MyDataRow(
      keyText: row.displayName,
      value: row.displayValue,
      isNative: row.isNative,
      onTap: () => _openHistory(row),
    );

    if (row.isNative) {
      return tile;
    }

    return Dismissible(
      key: ValueKey('${sec.categoryName}_${row.definitionName}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) => _confirmDelete(row),
      onDismissed: (_) => _removeRowFromState(row),
      child: tile,
    );
  }
}
