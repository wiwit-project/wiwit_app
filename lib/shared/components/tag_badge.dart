import 'package:material_ui/material_ui.dart';

import '../utils/tag_color_utils.dart';

/// The tag pill widget
class TagBadge extends StatelessWidget {
  const TagBadge({super.key, required this.name, this.color});

  final String name;
  final String? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tagColor = parseTagColor(color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        name,
        maxLines: 1,
        overflow: .ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: .w600,
          color: tagColor == null
              ? colorScheme.onSurfaceVariant
              : tagTextColor(tagColor),
        ),
      ),
    );
  }
}
