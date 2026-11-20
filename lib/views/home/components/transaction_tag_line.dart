import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/components/tag_badge.dart';
import '../../../shared/models/wiwit_api/transactions/transaction_response.dart';

const _gap = 6.0;
const _minChipWidth = 40.0;
const _maxVisibleTags = 1;

/// Tag will show in full for up to [_maxVisibleTags], then it will display count
/// of extra tags we have
int visibleTagCount({
  required double available,
  required double categoryWidth,
  required List<double> chipWidths,
  required double moreChipWidth,
  double gap = _gap,
  double minChipWidth = _minChipWidth,
  int maxVisible = _maxVisibleTags,
}) {
  if (chipWidths.isEmpty || maxVisible < 1) return 0;

  double reserveAfter(int index) =>
      index < chipWidths.length - 1 ? gap + moreChipWidth : 0;

  final firstMin = chipWidths.first < minChipWidth
      ? chipWidths.first
      : minChipWidth;
  if (categoryWidth + gap + firstMin + reserveAfter(0) > available) return 0;

  var used = categoryWidth + gap + chipWidths.first;
  var count = 1;
  final limit = chipWidths.length < maxVisible ? chipWidths.length : maxVisible;
  for (var i = 1; i < limit; i++) {
    if (used + gap + chipWidths[i] + reserveAfter(i) > available) break;
    used += gap + chipWidths[i];
    count++;
  }
  return count;
}

/// The category label and tags
class TransactionTagLine extends StatelessWidget {
  const TransactionTagLine({
    super.key,
    required this.category,
    required this.tags,
    this.style,
  });

  final String category;
  final List<TransactionTagResponse> tags;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return Text(category, style: style);

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScaler = MediaQuery.textScalerOf(context);
        final textDirection = Directionality.of(context);
        final categoryStyle = DefaultTextStyle.of(context).style.merge(style);

        double measure(String text, TextStyle style) {
          final painter = TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textScaler: textScaler,
            textDirection: textDirection,
          )..layout();
          final width = painter.width;
          painter.dispose();
          return width;
        }

        double chipWidth(String label) {
          final width =
              measure(label, TagBadge.denseTextStyle) +
              TagBadge.densePadding.horizontal;
          return width < TagBadge.denseMaxWidth
              ? width
              : TagBadge.denseMaxWidth;
        }

        final available = constraints.maxWidth - 1;
        final categoryWidth = measure(category, categoryStyle);
        final moreChipWidth = chipWidth('+${tags.length}');
        final count = visibleTagCount(
          available: available,
          categoryWidth: categoryWidth,
          chipWidths: [for (final tag in tags) chipWidth(tag.name)],
          moreChipWidth: moreChipWidth,
        );
        final hidden = tags.length - count;
        final showMore =
            hidden > 0 &&
            (count > 0 || categoryWidth + _gap + moreChipWidth <= available);

        if (count == 0 && !showMore) {
          return Text(category, style: style, maxLines: 1, overflow: .ellipsis);
        }

        return Row(
          children: [
            Text(category, style: style, maxLines: 1),
            for (var i = 0; i < count; i++) ...[
              const Gap(_gap),
              if (i == 0) Flexible(child: _chip(tags[i])) else _chip(tags[i]),
            ],
            if (showMore) ...[
              const Gap(_gap),
              Semantics(
                label: '$hidden more ${hidden == 1 ? 'tag' : 'tags'}',
                excludeSemantics: true,
                child: TagBadge(name: '+$hidden', dense: true),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _chip(TransactionTagResponse tag) =>
      TagBadge(name: tag.name, color: tag.color, dense: true);
}
