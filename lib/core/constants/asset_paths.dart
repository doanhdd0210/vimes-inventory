/// Typed references to bundled assets. Keeps asset strings out of widgets and
/// makes missing-asset mistakes a compile-time grep away.
class AssetPaths {
  const AssetPaths._();

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';

  static const String logo = '$_images/logo.png';
  static const String placeholder = '$_images/placeholder.png';
  static const String emptyBox = '$_icons/empty_box.svg';
}
