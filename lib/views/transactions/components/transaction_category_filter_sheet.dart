import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/components/search_text_field.dart';
import '../../../shared/models/wiwit_api/categories/category_response.dart';
import '../../../shared/providers/chopper_provider.dart';

/// Includes inactive categories used by historical records.
class TransactionCategoryFilterSheet extends ConsumerStatefulWidget {
  const TransactionCategoryFilterSheet({super.key, this.selectedId});
  final int? selectedId;

  @override
  ConsumerState<TransactionCategoryFilterSheet> createState() =>
      _TransactionCategoryFilterSheetState();
}

class _TransactionCategoryFilterSheetState
    extends ConsumerState<TransactionCategoryFilterSheet> {
  final _searchController = TextEditingController();
  late Future<List<CategoryResponse>> _categories;
  var _query = '';

  @override
  void initState() {
    super.initState();
    _categories = _loadCategories();
  }

  Future<List<CategoryResponse>> _loadCategories() async {
    final service = ref.read(categoryServiceProvider);
    final categories = <CategoryResponse>[];
    var page = 1;
    while (true) {
      final result = await service.getCategories(
        page: page,
        perPage: 100,
        showInactive: true,
        sort: .name,
      );
      categories.addAll(result.data);
      if (!mounted ||
          result.data.isEmpty ||
          result.meta.page >= result.meta.lastPage) {
        return categories;
      }
      page = result.meta.page + 1;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(
              'Filter by category',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SearchTextField(
              controller: _searchController,
              hintText: 'Search categories',
              onChanged: (value) =>
                  setState(() => _query = value.trim().toLowerCase()),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: FutureBuilder<List<CategoryResponse>>(
                future: _categories,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: .min,
                        children: [
                          const Text('Could not load categories.'),
                          TextButton(
                            onPressed: () =>
                                setState(() => _categories = _loadCategories()),
                            child: const Text('Try again'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final categories = snapshot.data!
                      .where(
                        (category) =>
                            category.name.toLowerCase().contains(_query),
                      )
                      .toList(growable: false);
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          title: const Text('All categories'),
                          trailing: widget.selectedId == null
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.pop(context, (category: null)),
                        );
                      }
                      final category = categories[index - 1];
                      return ListTile(
                        title: Text(category.name),
                        subtitle: category.isActive
                            ? null
                            : const Text('Inactive'),
                        trailing: category.id == widget.selectedId
                            ? const Icon(Icons.check)
                            : null,
                        onTap: () =>
                            Navigator.pop(context, (category: category)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
