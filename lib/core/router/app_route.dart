/// Route names + paths in one place. `name` is used for `context.goNamed(...)`,
/// `path` for the underlying [GoRoute].
enum AppRoute {
  login(name: 'login', path: '/login'),
  home(name: 'home', path: '/'),
  receiptForm(name: 'receiptForm', path: 'new'),
  receiptDetail(name: 'receiptDetail', path: 'detail/:id'),
  masterData(name: 'masterData', path: 'danh-muc'),
  stock(name: 'stock', path: 'ton-kho');

  const AppRoute({required this.name, required this.path});

  final String name;
  final String path;
}
