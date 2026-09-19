import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/models/wiwit_api/categories/category_response.dart';
import '../../shared/models/wiwit_api/categories/update_category_request.dart';
import '../../shared/models/wiwit_api/enums.dart';
import '../../shared/models/wiwit_api/problem_details.dart';
import '../../shared/providers/chopper_provider.dart';
import '../profile/components/settings_section_card.dart';
import 'components/category_form_sheet.dart';
import 'components/category_tile.dart';

/// The states the category list can be in.
enum _ListStatus { loading, ready, error }

/// Manages the categories.
class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  static const _perPage = 100;

  /// Long enough to reach for Undo, short enough to get out of the way.
  static const _undoDuration = Duration(seconds: 6);

  final _searchController = TextEditingController();
  final _categories = <CategoryResponse>[];

  var _status = _ListStatus.loading;
  var _isSearching = false;
  var _query = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches the categories from the server.
  Future<({List<CategoryResponse>? data, String? error})>
  _fetchCategories() async {
    try {
      final categoryList = await ref
          .read(categoryServiceProvider)
          .getCategories(
            perPage: _perPage,
            showInactive: true,
            sort: CategorySort.name,
          );

      return (data: categoryList.data, error: null);
    } on ProblemDetails catch (error) {
      return (data: null, error: error.detail);
    } catch (error) {
      return (data: null, error: '$error');
    }
  }

  Future<void> _loadCategories() async {
    final result = await _fetchCategories();

    if (!mounted) return;

    setState(() {
      if (result.data == null) {
        _status = _ListStatus.error;
        _errorMessage = result.error;
        return;
      }

      _errorMessage = null;
      _status = _ListStatus.ready;
      _categories
        ..clear()
        ..addAll(result.data!);
    });
  }

  List<CategoryResponse> get _visibleCategories {
    final query = _query.toLowerCase();

    if (query.isEmpty) return _categories;

    return _categories
        .where((category) => category.name.toLowerCase().contains(query))
        .toList();
  }

  void _showMessage(String message, {VoidCallback? onUndo}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          persist: false,
          duration: _undoDuration,
          action: onUndo == null
              ? null
              : SnackBarAction(label: 'Undo', onPressed: onUndo),
        ),
      );
  }

  void _replaceCategory(CategoryResponse category) {
    final index = _categories.indexWhere((entry) => entry.id == category.id);
    if (index < 0) return;

    setState(() => _categories[index] = category);
  }

  Future<void> _setActive(
    CategoryResponse category, {
    required bool isActive,
    bool canUndo = true,
  }) async {
    if (!mounted) return;

    _replaceCategory(category.copyWith(isActive: isActive));

    try {
      await ref
          .read(categoryServiceProvider)
          .updateCategory(
            category.id,
            UpdateCategoryRequest(isActive: isActive),
          );
    } on ProblemDetails catch (error) {
      if (!mounted) return;

      _replaceCategory(category);
      _showMessage(error.detail);
      return;
    }

    if (!mounted || !canUndo) return;

    _showMessage(
      isActive
          ? '"${category.name}" is back in the picker.'
          : '"${category.name}" hidden.',
      onUndo: () => _setActive(category, isActive: !isActive, canUndo: false),
    );
  }

  void _openForm({CategoryResponse? category}) {
    showCategoryFormSheet(
      context: context,
      category: category,
      onSaved: _loadCategories,
    );
  }

  void _stopSearching() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
      _query = '';
    });
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
                hintText: 'Search categories',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
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
        Expanded(
          child: Text(
            'Categories',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: .w700),
          ),
        ),
        IconButton(
          onPressed: _categories.isEmpty
              ? null
              : () => setState(() => _isSearching = true),
          icon: const Icon(Icons.search),
          tooltip: 'Search',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final message = _query.isNotEmpty
        ? 'Nothing matches "$_query".'
        : 'No categories yet. Add one to start grouping your transactions.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 32),
      child: Text(
        message,
        textAlign: .center,
        style: TextStyle(color: Theme.of(context).colorScheme.outline),
      ),
    );
  }

  Widget _buildErrorCard() {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSectionCard(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              _errorMessage ?? 'Could not load categories.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(12),
            Align(
              alignment: .centerRight,
              child: TextButton.icon(
                onPressed: _loadCategories,
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
    final colorScheme = Theme.of(context).colorScheme;
    final categories = _visibleCategories;

    if (categories.isEmpty) return _buildEmptyState();

    return SettingsSectionCard(
      child: Column(
        children: [
          for (var index = 0; index < categories.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
              ),
            CategoryTile(
              category: categories[index],
              onTap: () => _openForm(category: categories[index]),
              onActiveChanged: (isActive) =>
                  _setActive(categories[index], isActive: isActive),
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
        onRefresh: _loadCategories,
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
        tooltip: 'New category',
      ),
    );
  }
}
