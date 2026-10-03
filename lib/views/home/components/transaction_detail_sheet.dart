import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/models/wiwit_api/enums.dart';
import '../../../shared/models/wiwit_api/problem_details.dart';
import '../../../shared/models/wiwit_api/transactions/transaction_response.dart';
import '../../../shared/providers/chopper_provider.dart';
import '../../../shared/utils/format_utils.dart';

/// What the detail sheet was closed for.
enum TransactionDetailResult { edit, deleted }

/// The read only view of a transaction.
///
/// Pops with [TransactionDetailResult.edit] or [TransactionDetailResult.deleted]
/// for further actions.
class TransactionDetailSheet extends ConsumerStatefulWidget {
  const TransactionDetailSheet({super.key, required this.transaction});

  final TransactionResponse transaction;

  @override
  ConsumerState<TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

class _TransactionDetailSheetState
    extends ConsumerState<TransactionDetailSheet> {
  static const _actionHeight = 52.0;

  Future<void> _confirmDelete() async {
    final transaction = widget.transaction;
    String? failure;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDialog(
        title: 'Delete this transaction?',
        message: "This transaction will be deleted. This can't be undone.",
        confirmLabel: 'Delete',
        action: () async {
          try {
            await ref
                .read(transactionServiceProvider)
                .deleteTransaction(transaction.id);
          } on ProblemDetails catch (error) {
            failure = error.detail;
          } catch (error) {
            failure = '$error';
          }
        },
      ),
    );

    if (confirmed != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    // A failed delete leaves the sheet open, so the record is still there to
    // try again on.
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure!)));
      return;
    }

    Navigator.pop(context, TransactionDetailResult.deleted);
    messenger.showSnackBar(
      const SnackBar(content: Text('Transaction deleted.')),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // The same heading the form sheet wears, so the two read as one pair.
        const Expanded(
          child: Text(
            'Transaction',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildAmount(BuildContext context, {required bool isIncome}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '${isIncome ? '+' : '-'}RM',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Gap(8),
        Flexible(
          child: Text(
            formatAmount(parseAmountInCents(widget.transaction.amount)),
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontSize: 36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFootnote(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final createdAt = widget.transaction.createdAt.toLocal();
    final updatedAt = widget.transaction.updatedAt.toLocal();

    // Every record updates itself on save, so only call it edited once the
    // timestamps have actually drifted apart.
    final wasEdited = updatedAt.difference(createdAt).inMinutes >= 1;

    final added = 'Added ${formatDateTime(createdAt)}';

    return Text(
      wasEdited
          ? '$added  ·  Edited ${_formatEditedAt(createdAt, updatedAt)}'
          : added,
      style: TextStyle(fontSize: 12, color: colorScheme.outline),
    );
  }

  String _formatEditedAt(DateTime createdAt, DateTime updatedAt) {
    if (DateUtils.isSameDay(createdAt, updatedAt)) return formatTime(updatedAt);

    return formatRelativeDate(updatedAt);
  }

  Widget _buildActions(BuildContext context, {required bool isIncome}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () =>
                Navigator.pop(context, TransactionDetailResult.edit),
            style: FilledButton.styleFrom(
              backgroundColor: isIncome
                  ? colorScheme.primary
                  : colorScheme.secondary,
              minimumSize: const Size.fromHeight(_actionHeight),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ),
        const Gap(10),
        SizedBox.square(
          dimension: _actionHeight,
          child: IconButton.filled(
            onPressed: _confirmDelete,
            style: IconButton.styleFrom(
              backgroundColor: colorScheme.errorContainer,
              foregroundColor: colorScheme.onErrorContainer,
              side: BorderSide(color: colorScheme.error.withValues(alpha: .3)),
            ),
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final transaction = widget.transaction;
    final isIncome = transaction.type == TransactionType.income;
    final notes = transaction.notes?.trim() ?? '';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const Gap(8),
              _buildHeader(context),
              const Gap(4),
              _buildAmount(context, isIncome: isIncome),
              const Gap(12),
              Text(
                transaction.title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(transaction.category?.name ?? 'Uncategorized'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(formatLongDate(transaction.transactionDate)),
                  ),
                ],
              ),
              if (notes.isNotEmpty) ...[
                const Gap(14),
                Text(
                  notes,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const Gap(14),
              _buildFootnote(context),
              const Gap(20),
              _buildActions(context, isIncome: isIncome),
            ],
          ),
        ),
      ),
    );
  }
}
