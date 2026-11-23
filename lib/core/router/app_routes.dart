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
