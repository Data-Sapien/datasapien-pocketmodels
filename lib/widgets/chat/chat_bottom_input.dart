import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_asset_icons.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';

/// Bottom input bar: attach (+), web-search toggle, text field, send/stop
/// button. Mirrors iOS `ChatBottomInputView` including the draft attachment
/// pill shown above the text field.
class ChatBottomInput extends StatefulWidget {
  const ChatBottomInput({
    super.key,
    this.onSend,
    this.onStop,
    this.onToggleWebSearch,
    this.onAttach,
    this.onRemoveDraftAttachment,
    this.isGenerating = false,
    this.isModelReady = false,
    this.isWebSearchEnabled = false,
    this.draftAttachmentName,
    this.draftImageThumbnail,
    this.onSendWhenModelNotReady,
  });

  final void Function(String text)? onSend;
  final VoidCallback? onStop;
  final ValueChanged<bool>? onToggleWebSearch;
  final VoidCallback? onAttach;
  final VoidCallback? onRemoveDraftAttachment;
  final VoidCallback? onSendWhenModelNotReady;
  final bool isGenerating;
  final bool isModelReady;
  final bool isWebSearchEnabled;

  /// When non-null, shows a pill above the text field with the filename and a
  /// close button that triggers [onRemoveDraftAttachment].
  final String? draftAttachmentName;

  /// When non-null, shows an image draft pill (thumbnail + label) above the input.
  final ImageProvider? draftImageThumbnail;

  @override
  State<ChatBottomInput> createState() => _ChatBottomInputState();
}

class _ChatBottomInputState extends State<ChatBottomInput> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLines = 5;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _hasText {
    final t = _controller.text.trim();
    return t.isNotEmpty;
  }

  bool get _hasDraft => widget.draftAttachmentName != null;

  bool get _hasDraftImage => widget.draftImageThumbnail != null;

  bool get _canSend =>
      (_hasText || _hasDraft || _hasDraftImage) && !widget.isGenerating;

  void _handleSend() {
    if (!_canSend) return;
    if (!widget.isModelReady) {
      widget.onSendWhenModelNotReady?.call();
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onSend?.call(_controller.text.trim());
    _controller.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasDraft || _hasDraftImage) ...[
              if (_hasDraft)
                _DraftAttachmentPill(
                  name: widget.draftAttachmentName!,
                  onRemove: widget.onRemoveDraftAttachment,
                )
              else
                _DraftImagePill(
                  thumbnail: widget.draftImageThumbnail!,
                  onRemove: widget.onRemoveDraftAttachment,
                ),
              const SizedBox(height: 6),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: widget.isGenerating
                        ? AppColor.textSecondary(context).withValues(alpha: 0.5)
                        : AppColor.textSecondary(context),
                  ),
                  onPressed:
                      widget.isGenerating ? null : widget.onAttach,
                  iconSize: 24,
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  icon: SvgPicture.asset(
                    AppAssetIcons.featureGlobe,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(
                      widget.isWebSearchEnabled
                          ? AppColor.primaryTint
                          : AppColor.textSecondary(context),
                      BlendMode.srcIn,
                    ),
                  ),
                  onPressed: widget.isGenerating
                      ? null
                      : () => widget.onToggleWebSearch
                          ?.call(!widget.isWebSearchEnabled),
                  iconSize: 22,
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText:
                          AppLocalizations.of(context)!.chat_hint_placeholder,
                      hintStyle: AppFont.body.copyWith(
                        color: AppColor.textSecondary(context),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                    style: AppFont.body.copyWith(
                      color: AppColor.textPrimary(context),
                    ),
                    maxLines: _maxLines,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: widget.isGenerating
                      ? Icon(
                          Icons.stop_circle,
                          color: AppColor.primaryTint,
                        )
                      : SvgPicture.asset(
                          AppAssetIcons.mainArrowUpCircleFill,
                          width: 24,
                          height: 24,
                          fit: BoxFit.contain,
                          colorFilter: ColorFilter.mode(
                            _canSend
                                ? AppColor.primaryTint
                                : colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                            BlendMode.srcIn,
                          ),
                        ),
                  onPressed: widget.isGenerating
                      ? widget.onStop
                      : (_canSend ? _handleSend : null),
                  iconSize: 28,
                  padding: const EdgeInsets.all(4),
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftAttachmentPill extends StatelessWidget {
  const _DraftAttachmentPill({
    required this.name,
    required this.onRemove,
  });

  final String name;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32, maxHeight: 32),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 4),
        decoration: BoxDecoration(
          color: AppColor.primaryTint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.primaryTint.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 16,
              color: AppColor.primaryTint,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFont.caption.copyWith(
                  color: AppColor.textPrimary(context),
                ),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                size: 16,
                color: AppColor.textSecondary(context),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints:
                  const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftImagePill extends StatelessWidget {
  const _DraftImagePill({
    required this.thumbnail,
    required this.onRemove,
  });

  final ImageProvider thumbnail;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 32, maxHeight: 32),
      child: Container(
        padding: const EdgeInsets.only(left: 10, right: 4),
        decoration: BoxDecoration(
          color: AppColor.primaryTint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColor.primaryTint.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image(
                image: thumbnail,
                width: 16,
                height: 16,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'Image',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFont.caption.copyWith(
                color: AppColor.textPrimary(context),
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                size: 16,
                color: AppColor.textSecondary(context),
              ),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
            ),
          ],
        ),
      ),
    );
  }
}
