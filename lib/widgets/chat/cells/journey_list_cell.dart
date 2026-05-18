import 'package:flutter/material.dart';

import '../../../models/journey_list_item.dart';
import '../../../theme/app_color.dart';
import '../../../theme/app_font.dart';
import '../../../utils/media_url_helper.dart';

/// Journey list item card (image + title + description). Mirrors iOS JourneyListCell.
class JourneyListCell extends StatelessWidget {
  const JourneyListCell({
    super.key,
    required this.item,
    this.onTap,
  });

  final JourneyListItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final imageUri = resolveManagedModelImageUrl(item.imageUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.secondaryBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUri != null
                      ? Image.network(
                          imageUri.toString(),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, url, error) => _placeholder(),
                        )
                      : _placeholder(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: AppFont.bodyBold.copyWith(
                          color: AppColor.textPrimary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: AppFont.caption.copyWith(
                          color: AppColor.textSecondary(context),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColor.primaryTint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.landscape,
        size: 32,
        color: AppColor.primaryTint.withValues(alpha: 0.5),
      ),
    );
  }
}
