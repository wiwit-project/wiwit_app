import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:material_ui/material_ui.dart';

import '../../../shared/components/confirm_dialog.dart';
import '../../../shared/components/tag_badge.dart';
import '../../../shared/models/wiwit_api/problem_details.dart';
import '../../../shared/models/wiwit_api/tags/tag_request.dart';
import '../../../shared/models/wiwit_api/tags/tag_response.dart';
import '../../../shared/providers/chopper_provider.dart';
import '../../../shared/utils/tag_color_utils.dart';

Future<void> showTagFormSheet({
  required BuildContext context,
  required VoidCallback onSaved,
  TagResponse? tag,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    showDragHandle: true,
    enableDrag: true,
    builder: (_) => TagFormSheet(tag: tag, onSaved: onSaved),
  );
}

class TagFormSheet extends ConsumerStatefulWidget {
  const TagFormSheet({super.key, required this.onSaved, this.tag});

  final VoidCallback onSaved;
  final TagResponse? tag;

  @override
  ConsumerState<TagFormSheet> createState() => _TagFormSheetState();
}

class _TagFormSheetState extends ConsumerState<TagFormSheet> {
  static const _palette = {
    'Red': '#ef4444',
    'Orange': '#f97316',
    'Yellow': '#eab308',
    'Green': '#22c55e',
    'Teal': '#14b8a6',
    'Cyan': '#06b6d4',
    'Blue': '#3b82f6',
    'Indigo': '#6366f1',
    'Purple': '#8b5cf6',
    'Pink': '#ec4899',
    'Slate': '#64748b',
  };

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _colorController = TextEditingController();
  final _random = Random();
  var _isSaving = false;

  bool get _isEditing => widget.tag != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.tag?.name ?? '';
    _descriptionController.text = widget.tag?.description ?? '';
    _colorController.text = widget.tag?.color ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges =>
      _nameController.text.trim() != (widget.tag?.name ?? '') ||
      _descriptionController.text.trim() !=
          (widget.tag?.description ?? '').trim() ||
      _colorController.text.trim().toLowerCase() !=
          (widget.tag?.color ?? '').toLowerCase();

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _showError(Object error, String fallback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error is ProblemDetails ? error.detail : fallback),
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final service = ref.read(tagServiceProvider);
      final request = TagRequest(
        name: _nameController.text.trim(),
        description: _nullIfEmpty(_descriptionController.text),
        color: _nullIfEmpty(_colorController.text),
      );

      final tag = widget.tag;
      if (tag == null) {
        await service.createTag(request);
      } else {
        await service.updateTag(tag.id, request);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(error, 'Could not save the tag. Please try again.');
      return;
    }

    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    widget.onSaved();
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Tag updated.' : 'Tag added.')),
    );
  }

  Future<void> _confirmDelete() async {
    final tag = widget.tag;
    if (tag == null || _isSaving) return;

    final service = ref.read(tagServiceProvider);
    Object? failure;

    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete "${tag.name}"?',
      message:
          'This tag will be removed from all transactions that use it. '
          'The transactions themselves will be kept.',
      confirmLabel: 'Delete',
      action: () async {
        try {
          await service.deleteTag(tag.id);
        } catch (error) {
          failure = error;
        }
      },
    );

    if (!mounted || !confirmed) return;

    // A failed delete leaves the sheet open so the user can try again.
    if (failure != null) {
      _showError(failure!, 'Could not delete the tag. Please try again.');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    widget.onSaved();
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('"${tag.name}" deleted.')));
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
        title: _isEditing ? 'Discard changes?' : 'Discard tag?',
        message: 'What you entered will not be saved.',
        confirmLabel: 'Discard',
        action: () async {},
      ),
    );

    if (!mounted || discarded != true) return;
    Navigator.pop(context);
  }

  void _randomizeColor() {
    final hex = _random.nextInt(0x1000000).toRadixString(16).padLeft(6, '0');
    setState(() => _colorController.text = '#$hex');
  }

  Widget _buildColorPicker(InputDecoration decoration) {
    final value = _colorController.text.trim();
    final name = _nameController.text.trim();

    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _colorController,
                enabled: !_isSaving,
                autocorrect: false,
                enableSuggestions: false,
                maxLength: 7,
                textInputAction: .done,
                decoration: decoration.copyWith(
                  counterText: '', // disable counter text
                  isDense: true,
                  labelText: 'Color (optional)',
                  hintText: '#3b82f6',
                  suffixIcon: value.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear color',
                          onPressed: _isSaving
                              ? null
                              : () => setState(_colorController.clear),
                          icon: const Icon(Icons.close),
                        ),
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  final color = value?.trim() ?? '';
                  return color.isEmpty || parseTagColor(color) != null
                      ? null
                      : 'Enter a color like #3b82f6.';
                },
              ),
            ),
            const Gap(12),
            Tooltip(
              message: 'Random color',
              child: ElevatedButton(
                onPressed: _isSaving ? null : _randomizeColor,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.shuffle),
              ),
            ),
          ],
        ),
        const Gap(8),
        SingleChildScrollView(
          scrollDirection: .horizontal,
          child: Row(
            children: [
              for (final entry in _palette.entries)
                IconButton.filled(
                  tooltip: entry.key,
                  onPressed: _isSaving
                      ? null
                      : () =>
                            setState(() => _colorController.text = entry.value),
                  style: IconButton.styleFrom(
                    backgroundColor: parseTagColor(entry.value),
                    foregroundColor: tagTextColor(parseTagColor(entry.value)!),
                    visualDensity: .compact,
                  ),
                  icon: value.toLowerCase() == entry.value
                      ? const Icon(Icons.check, size: 20)
                      : const SizedBox.square(dimension: 20),
                ),
            ],
          ),
        ),
        const Gap(16),
        Align(
          alignment: .centerLeft,
          child: TagBadge(name: name.isEmpty ? 'Preview' : name, color: value),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final decoration = InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey, width: 0),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
      fillColor: colorScheme.secondaryContainer,
      filled: true,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmClose();
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: _isSaving ? null : _confirmClose,
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                      ),
                      Expanded(
                        child: Text(
                          _isEditing ? 'Edit tag' : 'New tag',
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
                    maxLength: 255,
                    decoration: decoration.copyWith(
                      labelText: 'Name',
                      hintText: 'e.g. Work meal, Holiday to Singapore',
                    ),
                    onChanged: (_) => setState(() {}),
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
                    maxLength: 255,
                    decoration: decoration.copyWith(
                      labelText: 'Description (optional)',
                      hintText: 'What is this tag for?',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const Gap(12),
                  _buildColorPicker(decoration),
                  if (_isEditing) ...[
                    const Gap(16),
                    Divider(color: colorScheme.outlineVariant),
                    Align(
                      alignment: .centerLeft,
                      child: TextButton.icon(
                        onPressed: _isSaving ? null : _confirmDelete,
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Delete tag'),
                      ),
                    ),
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
