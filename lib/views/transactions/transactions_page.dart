import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../shared/components/header_text.dart';
import '../../shared/models/wiwit_api/categories/category_response.dart';
import '../../shared/models/wiwit_api/transactions/transaction_response.dart';
import '../../shared/providers/chopper_provider.dart';
import '../../shared/utils/format_utils.dart';
import '../home/components/transaction_detail_sheet.dart';
import '../home/components/transaction_form_sheet.dart';
import '../home/components/transaction_tile.dart';
import 'components/transaction_category_filter_sheet.dart';
import 'transactions_controller.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late final TransactionsController _transactions;
  CategoryResponse? _category;
  DateTimeRange? _dateRange;
  var _isSearching = false;

  bool get _hasActiveFilters =>
      _isSearching ||
      _transactions.isSearching ||
      _category != null ||
      _dateRange != null;

  @override
  void initState() {
    super.initState();
    _transactions = TransactionsController(
      ref.read(transactionServiceProvider),
    );
    _scrollController.addListener(_loadNearEnd);
    _transactions.refresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _transactions.dispose();
    super.dispose();
  }

  void _loadNearEnd() {
    if (!mounted ||
        !_scrollController.hasClients ||
        _transactions.error != null) {
      return;
    }
    if (_scrollController.position.extentAfter < 300) {
      _transactions.loadNextPage();
    }
  }

  Future<void> _applyFilters() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    return _transactions.setFilters(
      categoryId: _category?.id,
      dateRange: _dateRange,
    );
  }

  void _search(String query) {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _transactions.search(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _search('');
  }

  void _resetFilters() {
    final hadApiFilters = _category != null || _dateRange != null;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
      _category = null;
      _dateRange = null;
    });
    _clearSearch();
    if (hadApiFilters) _applyFilters();
  }

  void _handleBack() {
    if (_hasActiveFilters) {
      _resetFilters();
    } else {
      Navigator.maybePop(context);
    }
  }

  Widget _buildHeader() {
    if (_isSearching) {
      return Row(
        children: [
          IconButton(
            onPressed: _handleBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Reset filters',
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              textCapitalization: .sentences,
              textInputAction: .search,
              onChanged: _search,
              decoration: const InputDecoration(
                hintText: 'Search transactions',
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, child) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear search',
                  ),
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          onPressed: _handleBack,
          icon: const Icon(Icons.arrow_back),
          tooltip: _hasActiveFilters ? 'Reset filters' : 'Back',
        ),
        const SizedBox(width: 4),
        const Expanded(child: AppBarText('Transactions')),
        IconButton(
          onPressed: () => setState(() => _isSearching = true),
          icon: const Icon(Icons.search),
          tooltip: 'Search',
        ),
      ],
    );
  }

  Future<void> _chooseCategory() async {
    final result = await showModalBottomSheet<({CategoryResponse? category})>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      builder: (_) => TransactionCategoryFilterSheet(selectedId: _category?.id),
    );
    if (!mounted || result == null) return;
    setState(() => _category = result.category);
    await _applyFilters();
  }

  Future<void> _chooseDates() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 10, 12, 31),
      initialDateRange: _dateRange,
      helpText: 'Filter by transaction date',
    );
    if (!mounted || range == null) return;
    setState(() => _dateRange = range);
    await _applyFilters();
  }

  Future<void> _showDetail(TransactionResponse transaction) async {
    final result = await showModalBottomSheet<TransactionDetailResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );
    if (!mounted || result == null) return;
    switch (result) {
      case .deleted:
        await _transactions.refresh();
      case .edit:
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: false,
          enableDrag: false,
          builder: (_) => TransactionFormSheet(
            transaction: transaction,
            onSaved: _transactions.refresh,
          ),
        );
    }
  }

  Widget _buildFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        InputChip(
          showCheckmark: false,
          avatar: Icon(
            _category != null ? Icons.label : Icons.label_outline,
            size: 18,
          ),
          label: Text(_category?.name ?? 'All categories'),
          selected: _category != null,
          onPressed: _chooseCategory,
          onDeleted: _category == null
              ? null
              : () {
                  setState(() => _category = null);
                  _applyFilters();
                },
          deleteButtonTooltipMessage: 'Clear category filter',
        ),
        InputChip(
          showCheckmark: false,
          avatar: Icon(
            _dateRange != null ? Icons.date_range : Icons.date_range_outlined,
            size: 18,
          ),
          label: Text(
            _dateRange == null
                ? 'All dates'
                : '${formatDate(_dateRange!.start)} – ${formatDate(_dateRange!.end)}',
          ),
          selected: _dateRange != null,
          onPressed: _chooseDates,
          onDeleted: _dateRange == null
              ? null
              : () {
                  setState(() => _dateRange = null);
                  _applyFilters();
                },
          deleteButtonTooltipMessage: 'Clear date filter',
        ),
      ],
    );
  }

  Widget _buildFooter(bool isEmpty) {
    if (_transactions.isRefreshing) return const SizedBox.shrink();
    final error = _transactions.error;
    if (error != null) {
      return Column(
        children: [
          Text(error, textAlign: .center),
          TextButton.icon(
            onPressed: _transactions.loadNextPage,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      );
    }
    if (_transactions.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_transactions.hasMore) {
      return TextButton(
        onPressed: _transactions.loadNextPage,
        child: const Text('Load more'),
      );
    }
    if (isEmpty) {
      return Text(
        _transactions.isSearching || _category != null || _dateRange != null
            ? 'No transactions match your filters.'
            : 'No transactions yet.',
        textAlign: .center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildList() {
    // TODO: Simplify this when the API support sorting
    final transactions = _transactions.visibleTransactions
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    // Fill a short viewport after each page or search update. This also keeps
    // paging when a local search has no matches in the pages loaded so far.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNearEnd());
    return RefreshIndicator(
      onRefresh: () => _transactions.refresh(keepVisible: true),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: .onDrag,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: transactions.length + 1,
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: _buildFooter(transactions.isEmpty),
            );
          }
          final transaction = transactions[index];
          final date = transaction.transactionDate;
          final previousDate = index == 0
              ? null
              : transactions[index - 1].transactionDate;
          final startsMonth =
              previousDate == null ||
              date.year != previousDate.year ||
              date.month != previousDate.month;
          return Column(
            key: ValueKey(transaction.id),
            crossAxisAlignment: .stretch,
            children: [
              if (startsMonth)
                Padding(
                  padding: EdgeInsets.fromLTRB(4, index == 0 ? 8 : 24, 4, 8),
                  child: Semantics(
                    header: true,
                    child: Text(
                      formatMonthYear(date),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              TransactionTile(
                transaction: transaction,
                onTap: () => _showDetail(transaction),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasActiveFilters,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasActiveFilters) _resetFilters();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: .stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [_buildHeader(), _buildFilters()],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: _transactions,
                  builder: (context, child) => _buildList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
