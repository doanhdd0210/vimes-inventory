import 'package:flutter/widgets.dart';

class AppRadius {
  const AppRadius._();

  static const double sm = 6;
  static const double md = 10;
  static const double lg = 16;
  static const double pill = 999;

  static const BorderRadius allSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius allMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius allLg = BorderRadius.all(Radius.circular(lg));
}
