/// Build flavors. Keep in sync with the Android `productFlavors` and the iOS
/// schemes/configurations of the same name.
enum Flavor {
  dev,
  staging,
  prod;

  static Flavor fromName(String? name) => switch (name) {
    'prod' => Flavor.prod,
    'staging' => Flavor.staging,
    _ => Flavor.dev,
  };
}
