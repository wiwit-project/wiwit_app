import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/components/tag_badge.dart';
import '../../../shared/models/wiwit_api/tags/tag_response.dart';

class TagRow extends StatelessWidget {
  const TagRow({super.key, required this.tag, required this.onTap});

  final TagResponse tag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: .centerLeft,
                child: Tooltip(
                  message: tag.name,
                  child: TagBadge(name: tag.name, color: tag.color),
                ),
              ),
            ),
            const Gap(16),
            Expanded(
              child: Text(
                tag.description?.isNotEmpty == true ? tag.description! : '-',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
