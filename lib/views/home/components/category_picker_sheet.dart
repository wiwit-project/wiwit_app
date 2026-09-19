import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/models/wiwit_api/categories/add_category_request.dart';
import '../../../shared/models/wiwit_api/categories/category_response.dart';
import '../../../shared/models/wiwit_api/problem_details.dart';
import '../../../shared/providers/chopper_provider.dart';
import '../../categories/categories_page.dart';
import 'section_label.dart';

/// Opens the picker over the transaction form.
///
/// [onCategoriesManaged] fires when the manage page was visited from other
/// places.
Future<CategoryResponse?> showCategoryPickerSheet({
  required BuildContext context,
  required List<CategoryResponse> categories,
  int? selectedId,
  VoidCallback? onCategoriesManaged,
}) {
  return showModalBottomSheet<CategoryResponse>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (_) => CategoryPickerSheet(
      categories: categories,
      selectedId: selectedId,
      onCategoriesManaged: onCategoriesManaged,
    ),
  );
}

/// Searchable category list
class CategoryPickerSheet extends ConsumerStatefulWidget {
  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedId,
    this.onCategoriesManaged,
  });

  final List<CategoryResponse> categories;

  final int? selectedId;

  /// Called once the manage page has been opened and closed.
  final VoidCallback? onCategoriesManaged;

  @override
  ConsumerState<CategoryPickerSheet> createState() =>
      _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends ConsumerState<CategoryPickerSheet> {
  static const _minQueryLength = 2;

  static const _categoriesPerPage = 100;

  final _searchController = TextEditingController();

  /// initial categories state
  late var _categories = widget.categories;

  var _query = '';
  var _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearching => _query.length >= _minQueryLength;

  List<CategoryResponse> get _matches {
    if (!_isSearching) return const [];

    final query = _query.toLowerCase();

    return _categories
        .where((category) => category.name.toLowerCase().contains(query))
        .toList();
  }

  /// Only offer to create when the name is not already taken.
  bool get _canCreate =>
      _query.isNotEmpty &&
      !_categories.any(
        (category) => category.name.toLowerCase() == _query.toLowerCase(),
      );

  Future<void> _manageCategories() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const CategoriesPage()));

    if (!mounted) return;

    widget.onCategoriesManaged?.call();

    final List<CategoryResponse> categories;
    try {
      final categoryList = await ref
          .read(categoryServiceProvider)
          .getCategories(perPage: _categoriesPerPage);
      categories = categoryList.data;
    } on ProblemDetails {
      // ignore error when failed to fetch latest categories
      return;
    }

    if (!mounted) return;

    setState(() => _categories = categories);
  }

  Future<void> _create() async {
    setState(() => _isCreating = true);

    final CategoryResponse created;
    try {
      created = await ref
          .read(categoryServiceProvider)
          .createCategory(AddCategoryRequest(name: _query));
    } on ProblemDetails catch (error) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.detail)));
      return;
    }

    if (!mounted) return;

    Navigator.pop(context, created);
  }

  /// Bolds the matched run
  Widget _categoryName(String name, TextStyle? style) {
    if (!_isSearching) return Text(name, style: style);

    final start = name.toLowerCase().indexOf(_query.toLowerCase());
    if (start < 0) return Text(name, style: style);

    final end = start + _query.length;

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: name.substring(0, start)),
          TextSpan(
            text: name.substring(start, end),
            style: const TextStyle(fontWeight: .w700),
          ),
          TextSpan(text: name.substring(end)),
        ],
      ),
      style: style,
    );
  }

  Widget _buildCategoryTile(CategoryResponse category) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = category.id == widget.selectedId;

    return ListTile(
      enabled: !_isCreating,
      selected: isSelected,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.secondaryContainer,
        child: Icon(
          Icons.label_outline,
          size: 18,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
      title: _categoryName(category.name, null),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () => Navigator.pop(context, category),
    );
  }

  Widget _buildCreateTile() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      enabled: !_isCreating,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: colorScheme.primary,
        child: _isCreating
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Icon(Icons.add, size: 18, color: colorScheme.onPrimary),
      ),
      title: Text(
        'Create "$_query"',
        style: const TextStyle(fontWeight: .w600),
      ),
      onTap: _isCreating ? null : _create,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final matches = _matches;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose category',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: .w700),
                    ),
                  ),
                  TextButton(
                    onPressed: _isCreating ? null : _manageCategories,
                    child: const Text('Manage'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                controller: _searchController,
                enabled: !_isCreating,
                textCapitalization: .sentences,
                textInputAction: .search,
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search or create',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _isCreating
                              ? null
                              : () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                          icon: const Icon(Icons.close),
                          tooltip: 'Clear search',
                        ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 0),
                  ),
                  border: OutlineInputBorder(borderRadius: .circular(28)),
                  fillColor: colorScheme.secondaryContainer,
                  filled: true,
                ),
              ),
            ),
            const Gap(12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: 12),
                children: [
                  if (_canCreate) _buildCreateTile(),
                  if (_isSearching) ...[
                    const _PickerSectionLabel(label: 'Matches'),
                    if (matches.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                        child: Text(
                          'Nothing matches "$_query".',
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      )
                    else
                      for (final category in matches)
                        _buildCategoryTile(category),
                  ],
                  // The full list stays put underneath, so filtering never
                  // takes browsing away.
                  const _PickerSectionLabel(label: 'All categories'),
                  if (_categories.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'No categories yet. Type a name above to create one.',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    )
                  else
                    for (final category in _categories)
                      _buildCategoryTile(category),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickerSectionLabel extends StatelessWidget {
  const _PickerSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SectionLabel(label: label),
    );
  }
}
