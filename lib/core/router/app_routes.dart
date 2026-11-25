/// The four tabs, in order, plus the pushed search screen.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String packages = '/packages';
  static const String codes = '/codes';
  static const String more = '/more';

  static const List<String> tabs = [home, packages, codes, more];

  /// Pushed above the shell, with the keyboard up.
  static const String search = '/search';

  /// Packages tab opened on one segment (`mobile`, `mobileInternet`, `home`).
  static String packagesSegment(String segment) => '$packages?s=$segment';
}

/// Pushed (non-tab) routes, shown above the shell with swipe-back.
abstract final class ContentRoutes {
  static const String sectionPattern = '/section/:key';
  static const String itemPattern = '/item/:id';

  static String section(String key) => '/section/$key';
  static String item(String id) => '/item/${Uri.encodeComponent(id)}';
}
