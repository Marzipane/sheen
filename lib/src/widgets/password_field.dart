import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:sheen/sheen.dart';

/// A password field: a [SheenTextField] whose text stays hidden until the person taps the eye button.
///
/// The button says which way it goes ([SheenStrings.showPassword] / [SheenStrings.hidePassword]); the field offers
/// password autofill by default.
///
/// ```dart
/// SheenPasswordField(label: 'Password', controller: password, onSubmitted: (_) => signIn())
/// ```
///
/// {@category Inputs}
class SheenPasswordField extends StatefulWidget {
  /// A password field labelled [label].
  const SheenPasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.placeholder,
    this.autofillHints = const [AutofillHints.password],
    this.textInputAction,
    this.onSubmitted,
    this.error,
  });

  /// The label above the field.
  final String label;

  /// The hint shown while the field is empty.
  final String? placeholder;

  /// Holds the password.
  final TextEditingController controller;

  /// What the system may autofill; use `AutofillHints.newPassword` on sign-up forms.
  final Iterable<String> autofillHints;

  /// The keyboard's action button.
  final TextInputAction? textInputAction;

  /// Called when the keyboard's action button is pressed.
  final ValueChanged<String>? onSubmitted;

  /// An error message under the field.
  final String? error;

  @override
  State<SheenPasswordField> createState() => _SheenPasswordFieldState();
}

class _SheenPasswordFieldState extends State<SheenPasswordField> {
  bool _shown = false;

  @override
  Widget build(BuildContext context) {
    final t = context.sheen;
    final strings = SheenStrings.of(context);
    return SheenTextField(
      label: widget.label,
      placeholder: widget.placeholder,
      controller: widget.controller,
      obscureText: !_shown,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      textCapitalization: TextCapitalization.none,
      keyboardType: TextInputType.visiblePassword,
      error: widget.error,
      trailing: SheenPressable(
        onTap: () => setState(() => _shown = !_shown),
        semanticLabel: _shown ? strings.hidePassword : strings.showPassword,
        minSize: 32,
        child: SizedBox.square(
          dimension: 32,
          child: Center(
            child: SheenIcon(SheenIcons.eye, size: 20, color: _shown ? t.colors.accentText : t.colors.textTertiary),
          ),
        ),
      ),
    );
  }
}
