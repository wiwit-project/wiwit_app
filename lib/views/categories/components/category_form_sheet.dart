import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/models/wiwit_api/categories/add_category_request.dart';
import '../../../shared/models/wiwit_api/categories/category_response.dart';
import '../../../shared/models/wiwit_api/categories/update_category_request.dart';
import '../../../shared/models/wiwit_api/problem_details.dart';
import '../../../shared/providers/chopper_provider.dart';

/// The UI for adding or editing a [category] record
class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({super.key, required this.onSaved, this.category});

  final VoidCallback onSaved;

  /// The category being edited, null when adding a new one.
  final CategoryResponse? category;

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  static const _maxNameLength = 60;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late bool _isActive;
  var _isSaving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();

    final category = widget.category;
    _isActive = category?.isActive ?? true;
    _nameController.text = category?.name ?? '';
    _descriptionController.text = category?.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Whether there is anything worth warning about before closing.
  bool get _hasUnsavedChanges {
    final category = widget.category;
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (category == null) return name.isNotEmpty || description.isNotEmpty;

    return name != category.name ||
        description != (category.description ?? '').trim() ||
        _isActive != category.isActive;
  }

  /// Creates or updates
  Future<void> _submit(String name) async {
    final service = ref.read(categoryServiceProvider);
    final category = widget.category;
    final description = _descriptionController.text.trim();

    if (category == null) {
      await service.createCategory(
        AddCategoryRequest(
          name: name,
          description: description.isEmpty ? null : description,
        ),
      );
      return;
    }

    await service.updateCategory(
      category.id,
      UpdateCategoryRequest(
        name: name,
        description: description,
        isActive: _isActive,
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _submit(_nameController.text.trim());
    } on ProblemDetails catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.detail)));
      return;
    }

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isSaving = false);

    widget.onSaved();
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Category updated.' : 'Category added.'),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final category = widget.category;
    if (category == null || _isSaving) return;

    String? failure;

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ConfirmDialog(
        title: 'Delete "${category.name}"?',
        message:
            'Transactions filed under it become uncategorised. Hiding it '
            'keeps the history intact.',
        confirmLabel: 'Delete',
        action: () async {
          try {
            await ref.read(categoryServiceProvider).deleteCategory(category.id);
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

    // A failed delete leaves the sheet open, user can try again
    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure!)));
      return;
    }

    widget.onSaved();
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('"${category.name}" deleted.')),
    );
  }

  Future<void> _confirmClose() async {
    if (_isSaving) return;

    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }

    final discarded = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: _isEditing ? 'Discard changes?' : 'Discard category?',
        message: 'What you entered will not be saved.',
        confirmLabel: 'Discard',
        action: () async {},
      ),
    );

    if (!mounted || discarded != true) return;

    Navigator.pop(context);
  }

  Widget _buildActiveSwitch() {
    final colorScheme = Theme.of(context).colorScheme;

    return SwitchListTile(
      value: _isActive,
      onChanged: _isSaving
          ? null
          : (value) => setState(() => _isActive = value),
      title: const Text(
        'Active',
        style: TextStyle(fontSize: 15, fontWeight: .w600),
      ),
      subtitle: Text(
        'Shown when adding a transaction',
        style: TextStyle(fontSize: 12.5, color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  Widget _buildDeleteAction() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Divider(color: colorScheme.outlineVariant),
        Align(
          alignment: .centerLeft,
          child: TextButton.icon(
            onPressed: _isSaving ? null : _confirmDelete,
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Delete category'),
          ),
        ),
        const Gap(4),
        Text(
          'Deleting clears the category on every transaction that uses it. '
          'Hide it instead to keep the history.',
          style: TextStyle(fontSize: 12.5, color: colorScheme.outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inputDecoration = InputDecoration(
      labelText: 'Name',
      hintText: 'e.g. Groceries, Fuel, Rent',
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 0),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
      fillColor: colorScheme.secondaryContainer,
      filled: true,
    );

    return PopScope(
      // When pressed back, intercept by confirmation dialog
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        _confirmClose();
      },
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: .stretch,
                mainAxisSize: .min,
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
                  const Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isEditing ? 'Edit category' : 'New category',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: .w700,
                          ),
                        ),
                      ),
                      FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ],
                  ),
                  const Gap(16),
                  TextFormField(
                    controller: _nameController,
                    enabled: !_isSaving,
                    autofocus: !_isEditing,
                    textCapitalization: .sentences,
                    textInputAction: .next,
                    maxLength: _maxNameLength,
                    decoration: inputDecoration,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Enter a name.'
                        : null,
                  ),
                  const Gap(12),
                  TextFormField(
                    controller: _descriptionController,
                    enabled: !_isSaving,
                    textCapitalization: .sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: .newline,
                    minLines: 2,
                    maxLines: 4,
                    decoration: inputDecoration.copyWith(
                      labelText: 'Description (optional)',
                      hintText: 'What is this category for?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  // Only an existing category can be hidden.
                  if (_isEditing) ...[
                    _buildActiveSwitch(),
                    const Gap(8),
                    _buildDeleteAction(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the category form.
Future<void> showCategoryFormSheet({
  required BuildContext context,
  required VoidCallback onSaved,
  CategoryResponse? category,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: false,
    enableDrag: false,
    builder: (_) => CategoryFormSheet(category: category, onSaved: onSaved),
  );
}
