/// Route names + paths in one place. `name` is used for `context.goNamed(...)`,
/// `path` for the underlying [GoRoute].
enum AppRoute {
  home(name: 'home', path: '/'),
  sampleDetail(name: 'sampleDetail', path: 'detail/:id');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
