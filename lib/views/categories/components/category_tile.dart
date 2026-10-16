import 'package:material_ui/material_ui.dart';

import '../../../shared/models/wiwit_api/categories/category_response.dart';

/// A single category row.
class CategoryTile extends StatelessWidget {
  const CategoryTile({
    super.key,
    required this.category,
    this.onTap,
    this.onActiveChanged,
  });

  final CategoryResponse category;

  final VoidCallback? onTap;

  final ValueChanged<bool>? onActiveChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isActive = category.isActive;
    final description = category.description;

    // Differentiate style between active and hidden categories
    final foreground = isActive
        ? colorScheme.onSurface
        : colorScheme.onSurfaceVariant;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: isActive
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        child: Icon(
          isActive ? Icons.label_outline : Icons.visibility_off_outlined,
          size: 18,
          color: isActive
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      title: Text(
        category.name,
        maxLines: 1,
        overflow: .ellipsis,
        style: textTheme.bodyLarge?.copyWith(
          fontWeight: .w600,
          color: foreground,
        ),
      ),
      subtitle: description == null
          ? null
          : Text(
              description,
              maxLines: 1,
              overflow: .ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: Switch(value: isActive, onChanged: onActiveChanged),
    );
  }
}
