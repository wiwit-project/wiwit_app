import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/components/search_text_field.dart';
import '../../../shared/components/tag_badge.dart';
import '../../../shared/models/wiwit_api/problem_details.dart';
import '../../../shared/models/wiwit_api/tags/tag_request.dart';
import '../../../shared/models/wiwit_api/tags/tag_response.dart';
import '../../../shared/providers/chopper_provider.dart';
import '../../../shared/utils/tag_service_utils.dart';
import '../../tags/tags_page.dart';
import 'section_label.dart';

Future<List<TagResponse>?> showTagPickerSheet({
  required BuildContext context,
  required List<TagResponse> tags,
  required Set<int> selectedIds,
  VoidCallback? onTagsManaged,
}) {
  return showModalBottomSheet<List<TagResponse>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * 0.85,
    ),
    builder: (_) => TagPickerSheet(
      tags: tags,
      selectedIds: selectedIds,
      onTagsManaged: onTagsManaged,
    ),
  );
}

class TagPickerSheet extends ConsumerStatefulWidget {
  const TagPickerSheet({
    super.key,
    required this.tags,
    required this.selectedIds,
    this.onTagsManaged,
  });

  final List<TagResponse> tags;

  final Set<int> selectedIds;

  final VoidCallback? onTagsManaged;

  @override
  ConsumerState<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<TagPickerSheet> {
  static const _minQueryLength = 2;

  final _searchController = TextEditingController();

  late var _tags = widget.tags;
  late final _selectedIds = {...widget.selectedIds};

  var _query = '';
  var _isCreating = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearching => _query.length >= _minQueryLength;

  List<TagResponse> get _matches {
    if (!_isSearching) return const [];

    final query = _query.toLowerCase();

    return _tags
        .where((tag) => tag.name.toLowerCase().contains(query))
        .toList();
  }

  bool get _canCreate =>
      _query.isNotEmpty &&
      !_tags.any((tag) => tag.name.toLowerCase() == _query.toLowerCase());

  void _toggle(TagResponse tag) {
    setState(() {
      if (!_selectedIds.remove(tag.id)) _selectedIds.add(tag.id);
    });
  }

  void _done() {
    final picked = _tags.where((tag) => _selectedIds.contains(tag.id)).toList();
    Navigator.pop(context, picked);
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _showError(Object error, String fallback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is ProblemDetails ? error.detail : fallback),
      ),
    );
  }

  Future<void> _manageTags() async {
    await Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const TagsPage()));

    if (!mounted) return;

    widget.onTagsManaged?.call();

    final List<TagResponse> tags;
    try {
      tags = await ref.read(tagServiceProvider).getAllTags();
    } catch (_) {
      // Keep the list we have when the refresh fails.
      return;
    }

    if (!mounted) return;

    // Tags deleted on the manage page can no longer be picked.
    final ids = tags.map((tag) => tag.id).toSet();
    setState(() {
      _tags = tags;
      _selectedIds.retainAll(ids);
    });
  }

  Future<void> _create() async {
    setState(() => _isCreating = true);

    final TagResponse created;
    try {
      created = await ref
          .read(tagServiceProvider)
          .createTag(TagRequest(name: _query));
    } catch (error) {
      if (!mounted) return;
      setState(() => _isCreating = false);
      _showError(error, 'Could not create the tag. Please try again.');
      return;
    }

    if (!mounted) return;

    setState(() {
      _tags = [..._tags, created]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _selectedIds.add(created.id);
      _isCreating = false;
    });
    _clearQuery();
  }

  Widget _buildTagTile(TagResponse tag) {
    return CheckboxListTile(
      enabled: !_isCreating,
      value: _selectedIds.contains(tag.id),
      onChanged: (_) => _toggle(tag),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Align(
        alignment: .centerLeft,
        child: TagBadge(name: tag.name, color: tag.color),
      ),
    );
  }

  Widget _buildCreateTile() {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      enabled: !_isCreating,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
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

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: SectionLabel(label: label),
    );
  }

  Widget _buildEmptyText(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Text(
        text,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Choose tags',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: .w700),
                    ),
                  ),
                  TextButton(
                    onPressed: _isCreating ? null : _manageTags,
                    child: const Text('Manage'),
                  ),
                  const Gap(4),
                  FilledButton(
                    onPressed: _isCreating ? null : _done,
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SearchTextField(
                controller: _searchController,
                enabled: !_isCreating,
                hintText: 'Search or create',
                onChanged: (value) => setState(() => _query = value.trim()),
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
                    _buildSectionLabel('Matches'),
                    if (matches.isEmpty)
                      _buildEmptyText('Nothing matches "$_query".')
                    else
                      for (final tag in matches) _buildTagTile(tag),
                  ],
                  _buildSectionLabel('All tags'),
                  if (_tags.isEmpty)
                    _buildEmptyText(
                      'No tags yet. Type a name above to create one.',
                    )
                  else
                    for (final tag in _tags) _buildTagTile(tag),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
