// Central place for named route constants.
// Using constants avoids typos like '/logn' and makes routes easy to reuse.
class AppRoutes {
  AppRoutes._(); // Prevent instantiation.

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String registration = '/registration';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
}
