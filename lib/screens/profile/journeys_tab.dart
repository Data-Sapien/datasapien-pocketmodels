import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/journey_list_item.dart';
import '../../services/badge_manager.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import '../../widgets/chat/cells/journey_list_cell.dart';

/// Journeys tab: list of journeys from JourneyService; tap runs journey and refetches.
/// Matches iOS [JourneysViewController] (statuses, mark seen, errors).
class JourneysTab extends StatefulWidget {
  const JourneysTab({
    super.key,
    this.onMarkedSeen,
    this.scrollController,
  });

  /// Called after journeys are fetched and marked seen (clears profile tab badge).
  final VoidCallback? onMarkedSeen;
  final ScrollController? scrollController;

  @override
  State<JourneysTab> createState() => _JourneysTabState();
}

class _JourneysTabState extends State<JourneysTab> {
  List<Journey> _journeys = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchJourneys();
  }

  Future<void> _fetchJourneys() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final journeyService = DataSapien.getJourneyService();
      final list = await journeyService.getJourneys(
        tags: ['ai'],
        statuses: [
          JourneyStatus.notStarted,
          JourneyStatus.completed,
        ],
        onlyInAudience: true,
      );
      if (!mounted) return;
      setState(() {
        _journeys = list.reversed.toList();
        _loading = false;
      });
      await BadgeManager.instance.markAllJourneysAsSeen(_journeys);
      widget.onMarkedSeen?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _runJourney(Journey journey) async {
    try {
      final journeyService = DataSapien.getJourneyService();
      await journeyService.runJourney(journey.name, data: {});
      if (!mounted) return;
      await _fetchJourneys();
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      final l10n = AppLocalizations.of(context)!;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.error_title),
          content: Text(l10n.error_open_journey),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.ok_button),
            ),
          ],
        ),
      );
    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _journeys.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _journeys.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppFont.body.copyWith(
                  color: AppColor.textSecondary(context),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _fetchJourneys,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ),
        ),
      );
    }
    if (_journeys.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.no_journeys,
          style: AppFont.body.copyWith(
            color: AppColor.textSecondary(context),
          ),
        ),
      );
    }
    return Stack(
      children: [
        ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _journeys.length,
          itemBuilder: (context, index) {
            final journey = _journeys[index];
            final item = JourneyListItem(
              title: journey.metadata.title,
              description: journey.metadata.description ?? '',
              imageUrl: journey.metadata.imageUrl,
            );
            return JourneyListCell(
              item: item,
              onTap: () => _runJourney(journey),
            );
          },
        ),
        if (_loading && _journeys.isNotEmpty)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x33000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
