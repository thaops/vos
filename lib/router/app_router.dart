import 'package:get/get.dart';
import 'package:vos_flutter/feature/login/binding/login_binding.dart';
import 'package:vos_flutter/feature/login/presentation/view/login_screen.dart';
// import 'package:vos_flutter/feature/public_app_shell/auth/login_with_microsoft/login_with_microsoft.dart'; // DELETED
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/view/profile_screen.dart';
import 'package:vos_flutter/feature/profile/view/link_viags_screen.dart';
import 'package:vos_flutter/feature/news_detail/binding/news_detail_binding.dart';
import 'package:vos_flutter/feature/news_detail/presentation/view/news_detail_screen.dart';
import 'package:vos_flutter/feature/authorize/binding/authorize_binding.dart';
import 'package:vos_flutter/feature/authorize/presentation/view/authorize_screen.dart';
import 'package:vos_flutter/router/bottom_navigation_main.dart';

class AppRouter {
  // Route cha
  static const auth = '/auth';
  static const report = '/report';
  static const board = '/board';
  static const task = '/task';
  static const leave = '/leave';
  static const support = '/support';
  static const main = '/main';
  static const profile = '/profile';
  static const splash = '/splash';
  static const linkViags = '/profile/link-viags';

  // Route con cho auth
  static const login = '/auth/login';
  static const loginWithMicrosoft = '/auth/loginWithMicrosoft';

  // News routes
  static const newsDetail = '/news-detail';

  // Authorize routes
  static const authorize = '/authorize';

  static final List<GetPage> routes = [
    // Auth
    GetPage(name: login, page: () => LoginScreen(), binding: LoginBinding()),
    // GetPage(name: loginWithMicrosoft, page: () => LoginWithMicrosoft()), // DELETED

    // Main
    GetPage(name: main, page: () => MainScreen()),

    // Độc lập
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: linkViags,
      page: () => const LinkViagsScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: newsDetail,
      page: () => const NewsDetailScreen(),
      binding: NewsDetailBinding(),
    ),
    GetPage(
      name: authorize,
      page: () => const AuthorizeScreen(),
      binding: AuthorizeBinding(),
    ),
  ];
}
