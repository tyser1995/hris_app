import 'package:flutter/widgets.dart';

/// Generates employee codes from a configurable pattern string.
///
/// Supported tokens:
/// | Token  | Replaced with                               |
/// |--------|---------------------------------------------|
/// | `YYYY` | 4-digit year  (e.g. `2026`)                 |
/// | `YY`   | 2-digit year  (e.g. `26`)                   |
/// | `MM`   | 2-digit month (e.g. `03`)                   |
/// | `DD`   | 2-digit day   (e.g. `15`)                   |
/// | `###`  | Zero-padded sequence; width = `#` count     |
///
/// Example:
///   pattern `YY-E###-MM`, sequence 1, date 2026-03-15 → `26-E001-03`
///   pattern `YY-E###-MM`, sequence 2, date 2026-04-01 → `26-E002-04`
class EmployeeCodeGenerator {
  EmployeeCodeGenerator._();

  /// Generates a code by substituting all tokens in [pattern].
  static String generate(String pattern, int sequence, DateTime date) {
    final year2 = (date.year % 100).toString().padLeft(2, '0');
    final year4 = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    // Replace date tokens — order matters: YYYY before YY
    String result = pattern
        .replaceAll('YYYY', year4)
        .replaceAll('YY', year2)
        .replaceAll('MM', month)
        .replaceAll('DD', day);

    // Replace each run of `#` chars with zero-padded sequence number
    result = result.replaceAllMapped(
      RegExp(r'#+'),
      (m) => sequence.toString().padLeft(m.group(0)!.length, '0'),
    );

    return result;
  }

  /// Preview using the current date.
  static String preview(String pattern, {int sequence = 1}) =>
      generate(pattern, sequence, DateTime.now());

  /// Returns `true` if [pattern] contains at least one `#` (sequence token).
  static bool hasSequence(String pattern) => pattern.contains('#');

  /// Returns sample codes: [seq, seq+1, seq+2] based on today.
  static List<String> samples(String pattern, int currentSequence) {
    final now = DateTime.now();
    return List.generate(
      3,
      (i) => generate(pattern, currentSequence + i + 1, now),
    );
  }

  /// Inserts [token] at the cursor position of [controller].
  static void insertToken(TextEditingController controller, String token) {
    final text = controller.text;
    final sel = controller.selection;
    final start = sel.start < 0 ? text.length : sel.start;
    final end = sel.end < 0 ? text.length : sel.end;
    final newText = text.replaceRange(start, end, token);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: start + token.length),
    );
  }
}

/// Available pattern tokens shown as helper chips in the settings UI.
class PatternToken {
  final String token;
  final String description;
  final String example;

  const PatternToken({
    required this.token,
    required this.description,
    required this.example,
  });

  static const List<PatternToken> all = [
    PatternToken(token: 'YY', description: '2-digit year', example: '26'),
    PatternToken(token: 'YYYY', description: '4-digit year', example: '2026'),
    PatternToken(token: 'MM', description: '2-digit month', example: '03'),
    PatternToken(token: 'DD', description: '2-digit day', example: '15'),
    PatternToken(token: '###', description: '3-digit seq', example: '001'),
    PatternToken(token: '####', description: '4-digit seq', example: '0001'),
  ];
}
