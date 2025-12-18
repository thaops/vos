import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vos_flutter/common/utils/check_awaiting_services.dart';
import 'package:vos_flutter/feature/login/binding/login_binding.dart';
import 'package:vos_flutter/feature/login/presentation/view/login_screen.dart';
import 'package:vos_flutter/feature/profile/binding/profile_binding.dart';
import 'package:vos_flutter/feature/profile/presentation/controller/profile_controller.dart';
import 'package:vos_flutter/feature/profile/presentation/view/about_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/link_viags_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/personal_info_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/privacy_policy_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/profile_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/terms_of_service_screen.dart';
import 'package:vos_flutter/feature/profile/presentation/view/terms_screen.dart';
import 'package:vos_flutter/feature/news_detail/binding/news_detail_binding.dart';
import 'package:vos_flutter/feature/news_detail/presentation/view/news_detail_screen.dart';
import 'package:vos_flutter/feature/authorize/binding/authorize_binding.dart';
import 'package:vos_flutter/feature/authorize/presentation/view/authorize_screen.dart';
import 'package:vos_flutter/feature/authorize_create/binding/authorize_create_binding.dart';
import 'package:vos_flutter/feature/authorize_create/presentation/view/authorize_create_screen.dart';
import 'package:vos_flutter/feature/time_off/binding/time_off_binding.dart';
import 'package:vos_flutter/feature/time_off/presentation/view/time_off_screen.dart';
import 'package:vos_flutter/feature/time_off_create/binding/time_off_create_binding.dart';
import 'package:vos_flutter/feature/time_off_create/presentation/view/time_off_create_screen.dart';
import 'package:vos_flutter/feature/time_off_detail/binding/time_off_detail_binding.dart';
import 'package:vos_flutter/feature/time_off_detail/presentation/view/time_off_detail_screen.dart';
import 'package:vos_flutter/feature/time_off_update/binding/time_off_update_binding.dart';
import 'package:vos_flutter/feature/time_off_update/presentation/view/time_off_update_screen.dart';
import 'package:vos_flutter/feature/vacation/binding/vacation_binding.dart';
import 'package:vos_flutter/feature/vacation/presentation/view/vacation_screen.dart';
import 'package:vos_flutter/router/bottom_navigation_main.dart';
import 'package:vos_flutter/router/main_binding.dart';

class AppRouter {
  // Route cha
  static const main = '/main';
  static const profile = '/profile';
  static const personalInfo = '/profile/personal-info';
  static const terms = '/profile/terms';
  static const linkViags = '/profile/link-viags';
  static const privacyPolicy = '/profile/privacy-policy';
  static const termsOfService = '/profile/terms-of-service';
  static const about = '/profile/about';

  // Route con cho auth
  static const login = '/auth/login';

  // News routes
  static const newsDetail = '/news-detail';

  // Authorize routes
  static const authorize = '/authorize';
  static const authorizeCreate = '/authorize/create';

  // Time Off routes
  static const timeOff = '/time-off';
  static const timeOffCreate = '/time-off/create';
  static const timeOffDetail = '/time-off/detail';
  static const timeOffUpdate = '/time-off/update';

  // Vacation routes
  static const vacation = '/vacation';

  // Wrapper widget để check awaiting và hiển thị màn hình tương ứng
  static Widget _loginWrapper() {
    return _LoginWrapperScreen();
  }

  static final List<GetPage> routes = [
    // Auth
    GetPage(name: login, page: _loginWrapper, binding: LoginBinding()),

    // Main
    GetPage(name: main, page: () => MainScreen(), binding: MainBinding()),

    // Độc lập
    GetPage(
      name: profile,
      page: () => ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: personalInfo,
      page: () => const PersonalInfoScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(name: terms, page: () => const TermsScreen()),
    GetPage(
      name: linkViags,
      page: () => const LinkViagsScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(name: privacyPolicy, page: () => const PrivacyPolicyScreen()),
    GetPage(name: termsOfService, page: () => const TermsOfServiceScreen()),
    GetPage(name: about, page: () => const AboutScreen()),
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
    GetPage(
      name: timeOff,
      page: () => const TimeOffScreen(),
      binding: TimeOffBinding(),
    ),
    GetPage(
      name: timeOffCreate,
      page: () => const TimeOffCreateScreen(),
      binding: TimeOffCreateBinding(),
    ),
    GetPage(
      name: timeOffDetail,
      page: () => const TimeOffDetailScreen(),
      binding: TimeOffDetailBinding(),
    ),
    GetPage(
      name: timeOffUpdate,
      page: () => const TimeOffUpdateScreen(),
      binding: TimeOffUpdateBinding(),
    ),
    GetPage(
      name: vacation,
      page: () => const VacationScreen(),
      binding: VacationBinding(),
    ),
  ];
}

// Wrapper widget để check awaiting và hiển thị màn hình tương ứng
class _LoginWrapperScreen extends StatefulWidget {
  @override
  State<_LoginWrapperScreen> createState() => _LoginWrapperScreenState();
}

class _LoginWrapperScreenState extends State<_LoginWrapperScreen> {
  bool _isLoading = true;
  bool _shouldShowLinkScreen = false;

  @override
  void initState() {
    super.initState();
    _checkAwaiting();
  }

  Future<void> _checkAwaiting() async {
    try {
      final checkAwaiting =
          await CheckAwaitingServices.createCheckAwaitingServices();
      final isAwaiting = await checkAwaiting.getawaiting();

      if (isAwaiting) {
        if (!Get.isRegistered<ProfileController>()) {
          ProfileBinding().dependencies();
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      if (mounted) {
        setState(() {
          _shouldShowLinkScreen = isAwaiting;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shouldShowLinkScreen = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _shouldShowLinkScreen
        ? const LinkViagsScreen()
        : const LoginScreen();
  }
}
