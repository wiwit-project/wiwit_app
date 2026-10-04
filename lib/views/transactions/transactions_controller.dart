import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart' show DateTimeRange;

import '../../shared/models/wiwit_api/problem_details.dart';
import '../../shared/models/wiwit_api/transactions/transaction_response.dart';
import '../../shared/services/apis/transaction_service.dart';

/// The transaction list page.
class TransactionsController extends ChangeNotifier {
  TransactionsController(this._service);

  static const _perPage = 25;
  final TransactionService _service;
  final _transactions = <TransactionResponse>[];

  /// Increases whenever the list is refreshed or its API filters change.
  /// Each request remembers this number before fetching. If the number has
  /// changed when it finishes, its response is ignored. For example, a request
  /// for all categories cannot overwrite results after selecting a category.
  var _generation = 0;

  /// The next API page to request
  var _nextPage = 1;

  /// Prevents requests and state updates after this controller is disposed.
  var _disposed = false;

  /// Trimmed, lowercase search text used to filter loaded transactions locally.
  var _query = '';

  /// Specifies category filters.
  int? _categoryId;

  /// Specifies period duration.
  DateTimeRange? _dateRange;

  /// Whether a page request is in progress, preventing duplicate requests.
  bool _isLoading = false;

  /// Keeps the current list visible refresh runs.
  bool _isRefreshing = false;

  /// Whether the API pagination metadata indicates more pages are available.
  bool _hasMore = true;

  /// The latest page request's error message.
  String? _error;

  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get isSearching => _query.isNotEmpty;

  List<TransactionResponse> get visibleTransactions {
    // TODO: Pass the search query to getTransactions when the API supports
    // full-text search
    return _transactions
        .where((transaction) {
          return _query.isEmpty ||
              [
                transaction.title,
                transaction.notes ?? '',
                transaction.category?.name ?? 'Uncategorized',
              ].any((text) => text.toLowerCase().contains(_query));
        })
        .toList(growable: false);
  }

  void search(String query) {
    _query = query.trim().toLowerCase();
    notifyListeners();
  }

  Future<void> setFilters({int? categoryId, DateTimeRange? dateRange}) {
    _categoryId = categoryId;
    _dateRange = dateRange;
    return refresh();
  }

  Future<void> refresh({bool keepVisible = false}) {
    if (_disposed) return Future.value();
    // A filter change or refresh supersedes any request already in flight.
    _generation++;
    _nextPage = 1;
    if (!keepVisible) _transactions.clear();
    _hasMore = true;
    _isLoading = false;
    _isRefreshing = keepVisible;
    _error = null;
    return loadNextPage();
  }

  Future<void> loadNextPage() async {
    if (_disposed || _isLoading || !_hasMore) return;

    final generation = _generation;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getTransactions(
        page: _nextPage,
        perPage: _perPage,
        categoryId: _categoryId,
        dateFrom: _dateRange?.start,
        dateTo: _dateRange?.end,
      );
      if (_disposed || generation != _generation) return;

      // Replace only after a successful first page, including refresh retries.
      if (_nextPage == 1) _transactions.clear();
      final ids = _transactions.map((transaction) => transaction.id).toSet();
      _transactions.addAll(
        result.data.where((transaction) => ids.add(transaction.id)),
      );
      _nextPage = result.meta.page + 1;
      _hasMore =
          result.meta.page < result.meta.lastPage && result.data.isNotEmpty;
    } catch (error) {
      if (_disposed || generation != _generation) return;
      _error = error is ProblemDetails
          ? error.detail
          : 'Could not load transactions. Please try again.';
    }

    if (_disposed || generation != _generation) return;
    _isLoading = false;
    _isRefreshing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
