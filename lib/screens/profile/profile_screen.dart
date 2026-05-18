import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import 'journeys_tab.dart';
import 'my_data_tab.dart';

/// Profile screen with two tabs: Journeys and My Data.
/// Matches iOS [ProfileViewController] (tabs, indicator, optional Journeys badge).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.initialJourneyUnreadCount = 0,
    this.isSheetMode = false,
    this.scrollController,
  });

  final int initialJourneyUnreadCount;
  final bool isSheetMode;
  final ScrollController? scrollController;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;
  late int _journeyTabBadgeCount;

  @override
  void initState() {
    super.initState();
    _journeyTabBadgeCount = widget.initialJourneyUnreadCount;
  }

  void _onJourneysMarkedSeen() {
    if (_journeyTabBadgeCount == 0) return;
    setState(() => _journeyTabBadgeCount = 0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final content = Column(
      children: [
        _buildTabBar(context, l10n),
        Expanded(
          child: IndexedStack(
            index: _selectedIndex,
            children: [
              JourneysTab(
                onMarkedSeen: _onJourneysMarkedSeen,
                scrollController:
                    _selectedIndex == 0 ? widget.scrollController : null,
              ),
              MyDataTab(
                scrollController:
                    _selectedIndex == 1 ? widget.scrollController : null,
              ),
            ],
          ),
        ),
      ],
    );

    if (widget.isSheetMode) {
      return ColoredBox(
        color: AppColor.primaryBackground(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                title: Text(
                  l10n.profile_title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColor.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      l10n.profile_close,
                      style: AppFont.button.copyWith(color: AppColor.primaryTint),
                    ),
                  ),
                ],
              ),
              Expanded(child: content),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          l10n.profile_title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.profile_close,
              style: AppFont.button.copyWith(color: AppColor.primaryTint),
            ),
          ),
        ],
      ),
      body: content,
    );
  }

  Widget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    const double barHeight = 48;
    const double indicatorHeight = 3;

    return Container(
      height: barHeight,
      color: AppColor.primaryBackground(context),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        _TabSegment(
                          label: l10n.profile_journeys,
                          selected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        if (_journeyTabBadgeCount > 0)
                          Positioned(
                            top: 4,
                            left: constraints.maxWidth / 2 + 8,
                            child: _JourneyTabBadge(count: _journeyTabBadgeCount),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: _TabSegment(
                  label: l10n.profile_my_data,
                  selected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
              ),
            ],
          ),
          Positioned(
            left: _selectedIndex == 0
                ? 0
                : MediaQuery.sizeOf(context).width / 2,
            right: _selectedIndex == 0
                ? MediaQuery.sizeOf(context).width / 2
                : 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              height: indicatorHeight,
              decoration: BoxDecoration(
                color: AppColor.primaryTint,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 1,
              color: AppColor.textSecondary(context).withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyTabBadge extends StatelessWidget {
  const _JourneyTabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final text = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _TabSegment extends StatelessWidget {
  const _TabSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: AppFont.bodyBold.copyWith(
              color: selected
                  ? AppColor.primaryTint
                  : AppColor.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
