import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../shared/models/wiwit_api/problem_details.dart';
import '../../shared/models/wiwit_api/profile/profile_response.dart';
import '../../shared/models/wiwit_api/transactions/transaction_response.dart';
import '../../shared/providers/chopper_provider.dart';
import '../../shared/providers/overview_provider.dart';
import '../../shared/utils/format_utils.dart';
import 'components/finance_overview_widget.dart';
import 'components/home_header.dart';
import 'components/transaction_detail_sheet.dart';
import 'components/transaction_form_sheet.dart';
import 'components/transaction_tile.dart';

/// The states the recent transactions list can be in.
enum _ListStatus { loading, ready, error }

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> with WidgetsBindingObserver {
  static const _transactionsPerPage = 12;
  static const _itemAnimationDuration = Duration(milliseconds: 350);
  static const _itemSlideOffset = Offset(0, -0.25);
  static const _spinnerRadius = 7.0;
  static const _spinnerFadeDuration = Duration(milliseconds: 200);
  static const _morningEndHour = 12;
  static const _afternoonEndHour = 17;
  static const _eveningEndHour = 21;

  final _listKey = GlobalKey<AnimatedListState>();
  final _transactions = <TransactionResponse>[];
  var _status = _ListStatus.loading;
  var _isRefreshing = false;
  String? _errorMessage;
  ProfileResponse? _userProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadProfile();
    _loadTransactions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state != AppLifecycleState.resumed) return;

    _refreshTransactions();
  }

  /// Fetches the latest transactions
  Future<({List<TransactionResponse>? data, String? error})>
  _fetchTransactions() async {
    try {
      final transactionList = await ref
          .read(transactionServiceProvider)
          .getTransactions(perPage: _transactionsPerPage);

      return (data: transactionList.data, error: null);
    } on ProblemDetails catch (error) {
      return (data: null, error: error.detail);
    } catch (error) {
      return (data: null, error: '$error');
    }
  }

  Future<void> _loadTransactions() async {
    _isRefreshing = true;
    final result = await _fetchTransactions();

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;

      if (result.data == null) {
        _status = _ListStatus.error;
        _errorMessage = result.error;
        return;
      }

      _replaceTransactions(result.data!);
    });
  }

  /// Fetches the profile name shown in the greeting.
  Future<void> _loadProfile() async {
    final ProfileResponse profile;
    try {
      profile = await ref.read(profileServiceProvider).getProfile();
    } on ProblemDetails {
      return;
    }

    if (!mounted) return;

    setState(() => _userProfile = profile);
  }

  /// Refetches and animates only what actually changed
  Future<void> _refreshTransactions() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    // trigger summary card refreshes
    ref.invalidate(txnOverviewProvider(month: formatMonthKey(DateTime.now())));

    final result = await _fetchTransactions();

    if (!mounted) return;

    setState(() {
      _isRefreshing = false;

      if (result.data == null) {
        _status = _ListStatus.error;
        _errorMessage = result.error;
        return;
      }

      // The AnimatedList is off screen here, so there is no state to animate
      // through. Swap the data instead and the list reads it when it builds.
      if (_status != _ListStatus.ready || _listKey.currentState == null) {
        _replaceTransactions(result.data!);
        return;
      }

      _applyIncoming(result.data!);
    });
  }

  void _replaceTransactions(List<TransactionResponse> incoming) {
    _transactions
      ..clear()
      ..addAll(incoming);
    _status = _ListStatus.ready;
  }

  void _applyIncoming(List<TransactionResponse> incoming) {
    final incomingIds = incoming.map((transaction) => transaction.id).toSet();

    // Drop entries that disappeared server side, back to front so the
    // remaining indexes stay valid while we mutate.
    for (var index = _transactions.length - 1; index >= 0; index--) {
      if (incomingIds.contains(_transactions[index].id)) continue;

      final removed = _transactions.removeAt(index);
      _listKey.currentState!.removeItem(
        index,
        (context, animation) => _buildAnimatedTile(removed, animation),
        duration: _itemAnimationDuration,
      );
    }

    // Animate in every entry we did not have yet, keeping the server order.
    final existingIds = _transactions
        .map((transaction) => transaction.id)
        .toSet();
    for (var index = 0; index < incoming.length; index++) {
      final transaction = incoming[index];
      if (existingIds.contains(transaction.id)) continue;

      final position = index.clamp(0, _transactions.length);
      _transactions.insert(position, transaction);
      _listKey.currentState!.insertItem(
        position,
        duration: _itemAnimationDuration,
      );
    }

    // to make sure edited data (that perhaps happened on backend side) would
    // be updated in the UI here
    final incomingById = {
      for (final transaction in incoming) transaction.id: transaction,
    };
    for (var index = 0; index < _transactions.length; index++) {
      final updated = incomingById[_transactions[index].id];
      if (updated == null) continue;

      _transactions[index] = updated;
    }
  }

  void _showTransactionForm({TransactionResponse? transaction}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      enableDrag: false,
      builder: (_) => TransactionFormSheet(
        transaction: transaction,
        onSaved: _refreshTransactions,
      ),
    );
  }

  /// Shows the read only detail.
  Future<void> _showTransactionDetail(TransactionResponse transaction) async {
    final result = await showModalBottomSheet<TransactionDetailResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      builder: (_) => TransactionDetailSheet(transaction: transaction),
    );

    if (result == null || !mounted) return;

    switch (result) {
      case TransactionDetailResult.edit:
        _showTransactionForm(transaction: transaction);
      case TransactionDetailResult.deleted:
        _refreshTransactions();
    }
  }

  /// Picks a greeting based on the current hour.
  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < _morningEndHour) return 'Good Morning';
    if (hour < _afternoonEndHour) return 'Good Afternoon';
    if (hour < _eveningEndHour) return 'Good Evening';

    return 'Good Night';
  }

  Widget _buildAnimatedTile(
    TransactionResponse transaction,
    Animation<double> animation,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
    );

    return SizeTransition(
      sizeFactor: curved,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: _itemSlideOffset,
            end: Offset.zero,
          ).animate(curved),
          child: TransactionTile(
            transaction: transaction,
            onTap: () => _showTransactionDetail(transaction),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactions() {
    // TODO: Replace the empty body with a shimmer placeholder list
    if (_status == _ListStatus.loading) {
      return const SizedBox.shrink();
    }

    if (_status == _ListStatus.error) {
      return Text(_errorMessage ?? 'Could not load transactions.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_transactions.isEmpty) const Text('No transactions yet.'),
        AnimatedList(
          key: _listKey,
          initialItemCount: _transactions.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index, animation) =>
              _buildAnimatedTile(_transactions[index], animation),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeader(
                  greeting: _getGreeting(),
                  profileDetail: _userProfile,
                ),
                const Gap(12),
                FinanceOverviewWidget(),
                const Gap(12),
                Row(
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Gap(8),
                    AnimatedOpacity(
                      opacity: _isRefreshing ? 1 : 0,
                      duration: _spinnerFadeDuration,
                      child: const CupertinoActivityIndicator(
                        radius: _spinnerRadius,
                      ),
                    ),
                    // Only show trigger refresh button on debug mode
                    if (kDebugMode)
                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red.shade200,
                          visualDensity: .compact,
                        ),
                        onPressed: () {
                          _refreshTransactions();
                        },
                        child: Text(
                          'Trigger refresh',
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                  ],
                ),
                const Gap(12),
                _buildTransactions(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTransactionForm,
        tooltip: 'Add Transaction',
        child: const Icon(Icons.add),
      ),
    );
  }
}
