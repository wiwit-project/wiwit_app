import 'package:material_ui/material_ui.dart';

/// The API's color format: `#` followed by six hex digits.
final _hexColorPattern = RegExp(r'^#[0-9a-fA-F]{6}$');

/// Stands in for WCAG's 0.05 luminance offset, biased so mid-tone pills get
/// white text. Increase it to switch to white text sooner.
const _whiteTextBias = 0.09;

/// Parses the API's six-digit hex color.
Color? parseTagColor(String? value) {
  if (value == null || !_hexColorPattern.hasMatch(value)) return null;

  return Color(0xFF000000 | int.parse(value.substring(1), radix: 16));
}

/// Chooses black or white text, whichever contrasts more with [background]
/// under the WCAG-style ratio biased by [_whiteTextBias].
Color tagTextColor(Color background) {
  final luminance = background.computeLuminance();
  final blackContrast = (luminance + 0.05) / _whiteTextBias;
  final whiteContrast = 1.05 / (luminance + _whiteTextBias);

  return blackContrast >= whiteContrast ? Colors.black : Colors.white;
}
