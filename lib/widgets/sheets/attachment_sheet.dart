import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';
import 'system_ui_sheet_scope.dart';

/// Option selected from the [AttachmentSheet], mirroring iOS
/// `AttachmentBottomSheetDelegate` (`didSelectDocument` / `didSelectScanText`).
enum AttachmentAction { documents, scanText, image }

/// Bottom sheet shown when the user taps the `+` attach button in the chat
/// input. Mirrors `AttachmentBottomSheetViewController.swift` (title + two
/// tiles for Documents and Scan Text).
class AttachmentSheet extends StatelessWidget {
  const AttachmentSheet({
    super.key,
    this.showImageOption = false,
  });

  final bool showImageOption;

  /// Convenience to present the sheet and await the user's selection.
  static Future<AttachmentAction?> show(BuildContext context) {
    return showModalBottomSheet<AttachmentAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const SystemUiSheetScope(child: AttachmentSheet()),
    );
  }

  static Future<AttachmentAction?> showWithImageOption(
    BuildContext context, {
    required bool showImageOption,
  }) {
    return showModalBottomSheet<AttachmentAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SystemUiSheetScope(
        child: AttachmentSheet(showImageOption: showImageOption),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Material(
        color: AppColor.primaryBackground(context),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.attachment_sheet_title,
                  style: AppFont.h2.copyWith(
                    color: AppColor.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 24),
                _AttachmentTile(
                  icon: Icons.description_outlined,
                  label: loc.attachment_sheet_documents,
                  onTap: () =>
                      Navigator.of(context).pop(AttachmentAction.documents),
                ),
                const SizedBox(height: 16),
                _AttachmentTile(
                  icon: Icons.document_scanner_outlined,
                  label: loc.attachment_sheet_scan_text,
                  onTap: () =>
                      Navigator.of(context).pop(AttachmentAction.scanText),
                ),
                if (showImageOption) ...[
                  const SizedBox(height: 16),
                  _AttachmentTile(
                    icon: Icons.photo_outlined,
                    label: 'Image',
                    onTap: () =>
                        Navigator.of(context).pop(AttachmentAction.image),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColor.secondaryBackground(context),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColor.textPrimary(context),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppFont.body.copyWith(
                    color: AppColor.textPrimary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
