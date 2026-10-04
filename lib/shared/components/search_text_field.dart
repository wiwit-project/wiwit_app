import 'package:material_ui/material_ui.dart';

/// The search field used in lists and pickers.
class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: .sentences,
      textInputAction: .search,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  onPressed: enabled
                      ? () {
                          controller.clear();
                          onChanged('');
                        }
                      : null,
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                ),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0),
        ),
        border: OutlineInputBorder(borderRadius: .circular(28)),
        fillColor: Theme.of(context).colorScheme.secondaryContainer,
        filled: true,
      ),
    );
  }
}
