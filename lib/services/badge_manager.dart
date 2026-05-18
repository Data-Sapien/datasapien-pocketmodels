import 'package:datasapien_sdk/datasapien_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks seen journey IDs and computes unread count for profile badge.
class BadgeManager extends ChangeNotifier {
  BadgeManager._();
  static final BadgeManager instance = BadgeManager._();

  static const String _seenJourneysKey = 'seen_journey_ids';

  Future<Set<String>> _getSeenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_seenJourneysKey);
    return list != null ? list.toSet() : {};
  }

  Future<void> _saveSeenIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_seenJourneysKey, ids.toList());
  }

  /// Returns the number of journeys that haven't been seen yet.
  Future<int> calculateUnreadJourneysCount(List<Journey> currentJourneys) async {
    var seenIds = await _getSeenIds();
    final currentIds = currentJourneys.map((j) => j.id).toSet();
    seenIds = seenIds.intersection(currentIds);
    if (seenIds.length < (await _getSeenIds()).length) {
      await _saveSeenIds(seenIds);
    }
    var count = 0;
    for (final j in currentJourneys) {
      if (!seenIds.contains(j.id)) count++;
    }
    return count;
  }

  /// Mark a single journey as seen.
  Future<void> markJourneyAsSeen(String id) async {
    final seen = await _getSeenIds();
    if (seen.contains(id)) return;
    seen.add(id);
    await _saveSeenIds(seen);
    notifyListeners();
  }

  /// Mark all given journeys as seen (e.g. when user opens Journeys tab).
  Future<void> markAllJourneysAsSeen(List<Journey> journeys) async {
    final seen = await _getSeenIds();
    var changed = false;
    for (final j in journeys) {
      if (!seen.contains(j.id)) {
        seen.add(j.id);
        changed = true;
      }
    }
    if (changed) {
      await _saveSeenIds(seen);
      notifyListeners();
    }
  }
}
