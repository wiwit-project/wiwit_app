import 'package:material_ui/material_ui.dart';

import '../utils/tag_color_utils.dart';

/// The tag pill widget
class TagBadge extends StatelessWidget {
  const TagBadge({
    super.key,
    required this.name,
    this.color,
    this.dense = false,
  });

  final String name;
  final String? color;

  final bool dense;

  static const denseMaxWidth = 128.0;
  static const densePadding = EdgeInsets.symmetric(horizontal: 7, vertical: 2);
  static const denseTextStyle = TextStyle(
    fontSize: 11,
    fontWeight: .w700,
    height: 1.25,
    letterSpacing: 0.2,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tagColor = parseTagColor(color);
    final textColor = tagColor == null
        ? colorScheme.onSurfaceVariant
        : tagTextColor(tagColor);
    final style = dense
        ? denseTextStyle.copyWith(color: textColor)
        : Theme.of(context).textTheme.labelMedium
              ?.copyWith(fontWeight: .w600, color: textColor);

    final badge = Container(
      padding: dense
          ? densePadding
          : const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: tagColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(name, maxLines: 1, overflow: .ellipsis, style: style),
    );

    if (!dense) return badge;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: denseMaxWidth),
      child: badge,
    );
  }
}
