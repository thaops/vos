import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:app_links/app_links.dart';
import 'package:calendar_view/calendar_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform, compute;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:vos_flutter/common/Services/device_udid.dart';
import 'package:vos_flutter/common/shared/auth/sign_out_clear.dart';
import 'package:vos_flutter/common/utils/check_awaiting_approval.dart';
import 'package:vos_flutter/common/utils/check_awaiting_services.dart';
import 'package:vos_flutter/common/utils/navigation_utils.dart';
import 'package:vos_flutter/common/utils/file_logger.dart';
import 'package:vos_flutter/common/widgets/splash_screen_widget.dart';
import 'package:vos_flutter/common/utils/splash_controller.dart';
import 'package:vos_flutter/core/configs/theme/app_theme.dart';
import 'package:vos_flutter/core/network/network_controller.dart';
import 'package:vos_flutter/router/app_router.dart';
import 'package:vos_flutter/common/services/deep_link_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

Future<bool> _isIPad() async {
  if (kIsWeb) return false;

  if (defaultTargetPlatform == TargetPlatform.macOS) {
    return false;
  }

  final deviceInfo = DeviceInfoPlugin();
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    final iosInfo = await deviceInfo.iosInfo;
    return iosInfo.model.toLowerCase().contains('ipad');
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    final mediaQuery = MediaQueryData.fromWindow(
      WidgetsBinding.instance.window,
    );
    final shortestSide = mediaQuery.size.shortestSide;
    return shortestSide >= 600;
  }
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _setupErrorHandlers();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Silent fail
  }

  await FileLogger.initialize();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    CalendarControllerProvider(
      controller: EventController(),
      child: const MyApp(initialDeepLink: null),
    ),
  );

  _initializeServicesInBackground();
}

void _setupErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);

    FileLogger.logError(
      details.exception,
      details.stack,
      context:
          'Flutter Error | Library: ${details.library} | Context: ${details.context}',
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    FileLogger.logError(error, stack, context: 'Platform Error');
    return true;
  };
}

void _initializeServicesInBackground() {
  Future.microtask(() async {
    try {
      final appLinks = AppLinks();
      await appLinks.getInitialLink();

      await Future.wait([
        _initializeCriticalServices(),
        _initializeNonCriticalServices(),
      ]);
    } catch (e, stackTrace) {
      await FileLogger.logError(
        e,
        stackTrace,
        context: 'Background initialization error',
      );
    }
  });
}

Future<void> _initializeCriticalServices() async {
  try {
    await Future.wait([GetStorage.init(), Hive.initFlutter()]);

    await Hive.openBox('google_user_box');
    Get.put(NetworkController());
    await Get.put(SignOutClear());
  } catch (e) {
    FileLogger.logError(e, null, context: 'Critical services init error');
  }
}

Future<void> _initializeNonCriticalServices() async {
  try {
    await Future.wait([
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
      generateUUID(),
    ]);

    // _lazyLoadCheckAwaitingApproval();
    _lazyLoadDateFormatting();
    _lazyCleanOldLogs();
  } catch (e) {
    FileLogger.logError(e, null, context: 'Non-critical services init error');
  }
}

void _lazyLoadCheckAwaitingApproval() {
  Future.microtask(() async {
    try {
      final serviceCheckawaiting =
          await CheckAwaitingServices.createCheckAwaitingServices();
      final checkAwaitingApproval = CheckAwaitingApproval();
      final packageInfo = await PackageInfo.fromPlatform();

      final result = await checkAwaitingApproval
          .checkAwaitingApproval(
            platform: Platform.isIOS ? "iOS" : "Android",
            appId: packageInfo.packageName,
            appBuild: packageInfo.buildNumber,
            appVersion: packageInfo.version,
            udid: Uuid().v4(),
          )
          .timeout(const Duration(seconds: 3), onTimeout: () => false);

      await serviceCheckawaiting.saveawaiting(result);
    } catch (e) {
      FileLogger.logError(e, null, context: 'Lazy load checkAwaitingApproval');
    }
  });
}

void _lazyLoadDateFormatting() {
  Future.microtask(() async {
    try {
      await compute(_loadDateFormattingInIsolate, 'vi_VN');
    } catch (e) {
      try {
        await initializeDateFormatting('vi_VN', null);
      } catch (e2) {
        // Silent fail
      }
    }
  });
}

void _lazyCleanOldLogs() {
  Future.microtask(() async {
    try {
      await compute(_cleanOldLogsInIsolate, null);
    } catch (e) {
      try {
        await FileLogger.cleanOldLogs();
      } catch (e2) {
        // Silent fail
      }
    }
  });
}

class MyApp extends StatefulWidget {
  final Uri? initialDeepLink;

  const MyApp({super.key, this.initialDeepLink});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Handle app resumed
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isIPad(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final isIPad = snapshot.data ?? false;

        Size designSize;
        if (defaultTargetPlatform == TargetPlatform.macOS) {
          designSize = const Size(1200, 800);
        } else if (isIPad) {
          designSize = const Size(768, 1024);
        } else {
          designSize = const Size(375, 812);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MainApp(initialDeepLink: widget.initialDeepLink);
          },
        );
      },
    );
  }
}

class MainApp extends StatefulWidget {
  final Uri? initialDeepLink;

  const MainApp({super.key, this.initialDeepLink});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: SplashScreen(initialDeepLink: widget.initialDeepLink),
      getPages: AppRouter.routes,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: NavigationUtils.navigatorKey,
      onUnknownRoute: (settings) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offAllNamed(AppRouter.main);
        });
        return GetPageRoute(
          settings: settings,
          page: () => const SizedBox.shrink(),
        );
      },
      unknownRoute: GetPage(
        name: '/unknown',
        page: () => SplashScreen(initialDeepLink: widget.initialDeepLink),
      ),
    );
  }
}

Future<void> generateUUID() async {
  DeviceUdid deviceUdid = await DeviceUdid.createDeviceUdid();
  var uuid = Uuid();
  deviceUdid.saveUdid(uuid.v4());
}

class SplashScreen extends StatelessWidget {
  final Uri? initialDeepLink;

  const SplashScreen({super.key, this.initialDeepLink});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashController());

    return SplashScreenWidget(onComplete: () {});
  }
}

Future<void> _loadDateFormattingInIsolate(String locale) async {
  await initializeDateFormatting(locale, null);
}

Future<void> _cleanOldLogsInIsolate(_) async {
  await FileLogger.cleanOldLogs();
}
