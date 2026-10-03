import 'package:material_ui/material_ui.dart';

/// Shared appbar text component for every page
class AppBarText extends StatelessWidget {
  const AppBarText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.headlineSmall?.copyWith(fontWeight: .w700),
    );
  }
}
