import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';

/// Shown when there are no messages. Matches iOS [EmptyChatStateView].
class EmptyChatState extends StatelessWidget {
  const EmptyChatState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColor.primaryTint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 42,
                color: AppColor.primaryTint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.chat_empty_heading,
              style: AppFont.h2.copyWith(
                color: AppColor.textPrimary(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.chat_empty_hint,
              style: AppFont.body.copyWith(
                color: AppColor.textSecondary(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
