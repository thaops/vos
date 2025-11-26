import 'package:get/get.dart';
import 'package:vos_flutter/feature/login/binding/login_binding.dart';
import 'package:vos_flutter/feature/login/presentation/view/login_screen.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/view/profile_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/link_viags_screen.dart';
import 'package:vos_flutter/feature/news_detail/binding/news_detail_binding.dart';
import 'package:vos_flutter/feature/news_detail/presentation/view/news_detail_screen.dart';
import 'package:vos_flutter/feature/authorize/binding/authorize_binding.dart';
import 'package:vos_flutter/feature/authorize/presentation/view/authorize_screen.dart';
import 'package:vos_flutter/feature/authorize_create/binding/authorize_create_binding.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/view/authorize_create_screen.dart';
import 'package:vos_flutter/router/bottom_navigation_main.dart';

class AppRouter {
  // Route cha
  static const main = '/main';
  static const profile = '/profile';
  static const linkViags = '/profile/link-viags';

  // Route con cho auth
  static const login = '/auth/login';

  // News routes
  static const newsDetail = '/news-detail';

  // Authorize routes
  static const authorize = '/authorize';
  static const authorizeCreate = '/authorize/create';

  static final List<GetPage> routes = [
    // Auth
    GetPage(name: login, page: () => LoginScreen(), binding: LoginBinding()),

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
    GetPage(
      name: authorizeCreate,
      page: () => const AuthorizeCreateScreen(),
      binding: AuthorizeCreateBinding(),
    ),
  ];
}
  