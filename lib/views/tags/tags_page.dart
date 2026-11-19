import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/components/header_text.dart';
import '../../shared/models/wiwit_api/problem_details.dart';
import '../../shared/models/wiwit_api/tags/tag_response.dart';
import '../../shared/providers/chopper_provider.dart';
import '../profile/components/settings_section_card.dart';
import 'components/tag_form_sheet.dart';
import 'components/tag_row.dart';

enum _ListStatus { loading, ready, error }

class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends ConsumerState<TagsPage> {
  static const _perPage = 100;

  final _searchController = TextEditingController();
  final _tags = <TagResponse>[];
  var _status = _ListStatus.loading;
  var _isSearching = false;
  var _query = '';
  var _loadVersion = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final version = ++_loadVersion;

    try {
      final service = ref.read(tagServiceProvider);
      final tags = <TagResponse>[];
      var page = 1;

      // Search must include tags beyond the API's first page.
      while (true) {
        final response = await service.getTags(page: page, perPage: _perPage);
        if (!mounted || version != _loadVersion) return;

        tags.addAll(response.data);
        if (page >= response.meta.lastPage) break;
        page++;
      }

      tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      setState(() {
        _tags
          ..clear()
          ..addAll(tags);
        _errorMessage = null;
        _status = _ListStatus.ready;
      });
    } catch (error) {
      if (!mounted || version != _loadVersion) return;

      setState(() {
        _errorMessage = error is ProblemDetails
            ? error.detail
            : 'Could not load tags. Please try again.';
        _status = _ListStatus.error;
      });
    }
  }

  List<TagResponse> get _visibleTags {
    final query = _query.toLowerCase();
    if (query.isEmpty) return _tags;

    return _tags.where((tag) {
      return tag.name.toLowerCase().contains(query) ||
          tag.description?.toLowerCase().contains(query) == true;
    }).toList();
  }

  void _openForm({TagResponse? tag}) {
    showTagFormSheet(context: context, tag: tag, onSaved: _loadTags);
  }

  /// Empties the search field and shows every tag again.
  void _clearQuery() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _stopSearching() {
    _clearQuery();
    setState(() => _isSearching = false);
  }

  Widget _buildHeader() {
    if (_isSearching) {
      return Row(
        children: [
          IconButton(
            onPressed: _stopSearching,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Close search',
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textCapitalization: .sentences,
              textInputAction: .search,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: const InputDecoration(
                hintText: 'Search tags',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              onPressed: _clearQuery,
              icon: const Icon(Icons.close),
              tooltip: 'Clear search',
            ),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        const Gap(4),
        const Expanded(child: AppBarText('Tags')),
        IconButton(
          onPressed: _tags.isEmpty
              ? null
              : () => setState(() => _isSearching = true),
          icon: const Icon(Icons.search),
          tooltip: 'Search',
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return SettingsSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              _errorMessage ?? 'Could not load tags.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            Align(
              alignment: .centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() => _status = _ListStatus.loading);
                  _loadTags();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    final tags = _visibleTags;
    final colorScheme = Theme.of(context).colorScheme;

    if (tags.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
        child: Text(
          _query.isNotEmpty
              ? 'Nothing matches "$_query".'
              : 'No tags yet. Add one for things like work meals or holidays.',
          textAlign: .center,
          style: TextStyle(color: colorScheme.outline),
        ),
      );
    }

    return SettingsSectionCard(
      child: Column(
        children: [
          for (var index = 0; index < tags.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              ),
            TagRow(
              tag: tags[index],
              onTap: () => _openForm(tag: tags[index]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    return switch (_status) {
      .loading => const Center(child: CircularProgressIndicator()),
      .error => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _buildErrorCard(),
      ),
      .ready => RefreshIndicator(
        onRefresh: _loadTags,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [_buildList()],
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildHeader(),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.add),
        label: const Text('New'),
        tooltip: 'New tag',
      ),
    );
  }
}
