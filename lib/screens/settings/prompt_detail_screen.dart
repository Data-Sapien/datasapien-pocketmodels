import 'package:flutter/material.dart';

import '../../models/prompt_item.dart';
import '../../theme/app_color.dart';
import '../../theme/app_font.dart';

/// Prompt detail: edit title and content; Save, Delete (custom only). [readOnly] for preset viewing (iOS parity).
class PromptDetailScreen extends StatefulWidget {
  const PromptDetailScreen({
    super.key,
    this.prompt,
    required this.onSave,
    required this.onDelete,
    this.readOnly = false,
  });

  /// Null when adding a new profile.
  final PromptItem? prompt;
  final void Function(PromptItem saved) onSave;
  final void Function(String promptId) onDelete;
  final bool readOnly;

  @override
  State<PromptDetailScreen> createState() => _PromptDetailScreenState();
}

class _PromptDetailScreenState extends State<PromptDetailScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.prompt?.title ?? '');
    _contentController =
        TextEditingController(text: widget.prompt?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (widget.readOnly) return;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and instructions are required')),
      );
      return;
    }
    final description =
        content.length > 40 ? '${content.substring(0, 40)}...' : content;
    final saved = PromptItem(
      id: widget.prompt?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      content: content,
      isPreset: false,
      icon: 'pencil',
    );
    widget.onSave(saved);
    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    if (widget.prompt == null || widget.prompt!.isPreset) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: const Text(
          'Are you sure you want to delete this personality profile? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onDelete(widget.prompt!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDelete =
        !widget.readOnly && widget.prompt != null && !widget.prompt!.isPreset;
    final titleText = widget.readOnly
        ? 'Profile'
        : widget.prompt == null
            ? 'New profile'
            : 'Edit profile';

    return Scaffold(
      backgroundColor: AppColor.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          titleText,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColor.textPrimary(context),
              ),
        ),
        actions: [
          if (!widget.readOnly)
            TextButton(
              onPressed: _handleSave,
              child: Text(
                'Save',
                style: TextStyle(
                  color: AppColor.primaryTint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          TextField(
            controller: _titleController,
            readOnly: widget.readOnly,
            decoration: InputDecoration(
              labelText: 'Profile Name (e.g. Recipe Critic)',
              labelStyle: TextStyle(color: AppColor.textSecondary(context)),
              filled: true,
              fillColor:
                  AppColor.secondaryBackground(context).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: AppFont.bodyBold.copyWith(
              color: AppColor.textPrimary(context),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'System instructions',
            style: AppFont.captionBold.copyWith(
              color: AppColor.textSecondary(context),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _contentController,
            readOnly: widget.readOnly,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'System instructions...',
              hintStyle: TextStyle(
                color: AppColor.textSecondary(context).withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor:
                  AppColor.secondaryBackground(context).withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              alignLabelWithHint: true,
            ),
            style: AppFont.body.copyWith(
              color: AppColor.textPrimary(context),
            ),
          ),
          if (canDelete) ...[
            const SizedBox(height: 32),
            TextButton.icon(
              onPressed: _handleDelete,
              icon:
                  const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              label: const Text(
                'Delete Profile',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
