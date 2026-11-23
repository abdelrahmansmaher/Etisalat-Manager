/// Route paths. Tab order follows doc 04 §4.1:
/// Home · Browse · Search (center) · Training · Me.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String browse = '/browse';
  static const String search = '/search';
  static const String training = '/training';
  static const String me = '/me';

  static const List<String> tabs = [home, browse, search, training, me];
  static const int searchTabIndex = 2;
}

/// Pushed (non-tab) routes, shown above the shell with swipe-back.
abstract final class ContentRoutes {
  static const String sectionPattern = '/section/:key';
  static const String itemPattern = '/item/:id';
  static const String review = '/review';

  static String section(String key) => '/section/$key';
  static String item(String id) => '/item/${Uri.encodeComponent(id)}';
}
