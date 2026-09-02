import 'package:flutter/material.dart';

/// Ergonomic accessors on [BuildContext]. Cuts `Theme.of(context)` noise.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get texts => Theme.of(this).textTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  bool get isCompact => MediaQuery.sizeOf(this).width < 600;

  void showSnack(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(this);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : null,
        ),
      );
  }

  Future<void> dismissKeyboard() async => FocusScope.of(this).unfocus();
}
