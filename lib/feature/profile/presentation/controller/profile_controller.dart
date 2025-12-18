import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/common/utils/check_awaiting_services.dart';
import 'package:vos_flutter/feature/banner/presentation/controller/banner_controller.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';
import 'package:vos_flutter/feature/profile/domain/models/user_profile.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/check_employee_status_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/check_viags_status_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/get_user_profile_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/link_viags_account_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/unlink_viags_account_usecase.dart';
import 'package:vos_flutter/feature/profile/domain/usecases/logout_usecase.dart';
import 'package:vos_flutter/feature/vacation/domain/usecases/get_vacation_list_usecase.dart';
import 'package:vos_flutter/feature/vacation/domain/models/vacation.dart';
import 'package:vos_flutter/feature/time_off/domain/usecases/get_personal_vacation_usecase.dart';
import 'package:vos_flutter/feature/time_off/domain/models/personal_vacation.dart';

class ProfileController extends GetxController {
  final GetUserProfileUsecase getUserProfileUsecase;
  final LinkViagsAccountUsecase linkViagsAccountUsecase;
  final UnlinkViagsAccountUsecase unlinkViagsAccountUsecase;
  final LogoutUsecase logoutUsecase;
  final CheckViagsStatusUsecase checkViagsStatusUsecase;
  final CheckEmployeeStatusUsecase checkEmployeeStatusUsecase;
  final GetVacationListUsecase? getVacationListUsecase;
  final GetPersonalVacationUsecase? getPersonalVacationUsecase;
  final CheckAwaitingServices checkAwaitingServices;

  ProfileController({
    required this.getUserProfileUsecase,
    required this.linkViagsAccountUsecase,
    required this.unlinkViagsAccountUsecase,
    required this.logoutUsecase,
    required this.checkViagsStatusUsecase,
    required this.checkEmployeeStatusUsecase,
    required this.checkAwaitingServices,
    this.getVacationListUsecase,
    this.getPersonalVacationUsecase,
  });

  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final Rx<GoogleUserDto?> googleUser = Rx<GoogleUserDto?>(null);
  final RxBool isLoading = false.obs;

  bool _isLoggingOut = false;
  bool get isLoggingOut => _isLoggingOut;

  final RxBool isViagsLinked = false.obs;
  final RxString viagsEmail = ''.obs;

  final RxBool isEmployee = false.obs;

  final RxBool isAwaiting = false.obs;

  final RxString linkViagsError = ''.obs;

  final RxList<Vacation> vacationList = <Vacation>[].obs;
  final RxDouble phepTon = 0.0.obs;
  final RxDouble overtimeTon = 0.0.obs;
  final Rx<PersonalVacation?> personalVacation = Rx<PersonalVacation?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    _loadGoogleUserAsync();
    loadViagsStatus();
    loadEmployeeStatus();
    loadAwaitingStatus();
  }

  Future<void> loadUserProfile() async {
    try {
      final result = await getUserProfileUsecase.call();
      if (result.isSuccess && result.data != null) {
        userProfile.value = result.data;
        isEmployee.value = true;
        await loadVacationData();
      } else {
        userProfile.value = null;
        isEmployee.value = false;
        vacationList.clear();
        phepTon.value = 0.0;
        overtimeTon.value = 0.0;
      }
    } catch (e) {
      userProfile.value = null;
      isEmployee.value = false;
      vacationList.clear();
      phepTon.value = 0.0;
      overtimeTon.value = 0.0;
    }
  }

  Future<void> loadViagsStatus() async {
    try {
      final status = await checkViagsStatusUsecase.call();
      final isLinked = status['isLinked'] as bool? ?? false;
      isViagsLinked.value = isLinked;

      if (!isLinked) {
        viagsEmail.value = '';
      } else {
        viagsEmail.value = status['email'] as String? ?? '';
      }
    } catch (e) {
      isViagsLinked.value = false;
      viagsEmail.value = '';
    }
  }

  void reloadViagsStatus() {
    loadViagsStatus();
  }

  Future<void> loadEmployeeStatus() async {
    try {
      isEmployee.value = userProfile.value != null;
    } catch (e) {
      isEmployee.value = false;
    }
  }

  void reloadEmployeeStatus() {
    loadEmployeeStatus();
  }

  Future<void> loadAwaitingStatus() async {
    try {
      final awaiting = await checkAwaitingServices.getawaiting();
      isAwaiting.value = awaiting;
    } catch (e) {
      isAwaiting.value = false;
    }
  }

  void reloadAwaitingStatus() {
    loadAwaitingStatus();
  }

  Future<void> _loadGoogleUserAsync() async {
    try {
      final box = Hive.box('google_user_box');
      final userData = box.get('current_user');

      if (userData != null) {
        googleUser.value = GoogleUserDto.fromJson(
          Map<String, dynamic>.from(userData),
        );
      } else {
        googleUser.value = null;
      }
    } catch (e) {
      googleUser.value = null;
    }
  }

  void refreshGoogleUser() {
    _loadGoogleUserAsync();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadUserProfile(),
      loadViagsStatus(),
      loadEmployeeStatus(),
    ]);
  }

  Future<void> logout() async {
    try {
      _isLoggingOut = true;

      await FirebaseAuth.instance.signOut();

      final googleSignIn = GoogleSignIn(scopes: ['email']);
      await googleSignIn.disconnect();

      final box = Hive.box('google_user_box');
      await box.delete('current_user');

      await logoutUsecase.call();
    } catch (e) {
      try {
        final box = Hive.box('google_user_box');
        await box.delete('current_user');
        await logoutUsecase.call();
      } catch (_) {
      }
    } finally {
      Future.delayed(const Duration(seconds: 2), () {
        _isLoggingOut = false;
      });
    }
  }

  Future<bool> linkViagsAccount(String name, String password) async {
    try {
      isLoading.value = true;
      linkViagsError.value = '';

      final result = await linkViagsAccountUsecase.call(name, password);

      if (result.isSuccess && result.data != null) {
        userProfile.value = result.data;

        await loadViagsStatus();
        isEmployee.value = true;

        if (googleUser.value != null &&
            userProfile.value?.email.isNotEmpty == true) {
          try {
            final box = Hive.box('google_user_box');
            final googleUserData = googleUser.value!.toJson();
            googleUserData['email'] = userProfile.value!.email;
            await box.put('current_user', googleUserData);
            googleUser.value = GoogleUserDto.fromJson(googleUserData);
            googleUser.refresh();
          } catch (e) {}
        }

        _resetBannerController();

        await loadVacationData();
        await loadPersonalVacation();

        return true;
      } else {
        final errorMsg = result.error ?? 'Không thể liên kết tài khoản VOS';
        linkViagsError.value = errorMsg;
        return false;
      }
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      linkViagsError.value = errorMsg.isNotEmpty
          ? errorMsg
          : 'Có lỗi xảy ra khi liên kết tài khoản';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _resetBannerController() {
    try {
      if (Get.isRegistered<BannerController>()) {
        final bannerController = Get.find<BannerController>();
        bannerController.banners.clear();
        bannerController.isLoading.value = true;
        bannerController.error.value = '';
      }
    } catch (e) {}
  }

  Future<bool> unlinkViagsAccount() async {
    try {
      isLoading.value = true;

      final result = await unlinkViagsAccountUsecase.call();

      if (result.isSuccess) {
        userProfile.value = null;

        isViagsLinked.value = false;
        viagsEmail.value = '';

        vacationList.clear();
        phepTon.value = 0.0;
        overtimeTon.value = 0.0;

        await loadViagsStatus();
        isEmployee.value = false;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String get displayName => userProfile.value?.userName ?? 'Người dùng';
  String get userCode => userProfile.value?.userCode ?? '';
  String get companyName => userProfile.value?.companyNameVN ?? '';
  String get email {
    if (isViagsLinked.value && viagsEmail.value.isNotEmpty) {
      return viagsEmail.value;
    }
    return userProfile.value?.email ?? '';
  }

  String get phone => userProfile.value?.phone ?? '';
  String get status => userProfile.value?.status ?? '';
  String get userType => userProfile.value?.userType ?? '';
  String get description => userProfile.value?.description ?? '';

  Future<void> loadVacationData() async {
    if (getVacationListUsecase == null) {
      return;
    }

    final profile = userProfile.value;
    if (profile == null) {
      return;
    }

    final hrId = profile.hrId > 0 ? profile.hrId : 1752;

    try {
      final currentYear = DateTime.now().year;
      final result = await getVacationListUsecase!.call(
        year: currentYear,
        hrId: hrId,
        viewData: '',
      );

      if (result.isSuccess && result.data != null && result.data!.isNotEmpty) {
        vacationList.assignAll(result.data!);

        final firstVacation = result.data!.first;
        if (firstVacation.phepTon != null) {
          phepTon.value = firstVacation.phepTon!;
        }
        if (firstVacation.overtimeTon != null) {
          overtimeTon.value = firstVacation.overtimeTon!;
        }
      } else {
        phepTon.value = 0.0;
        overtimeTon.value = 0.0;
        vacationList.clear();
      }
    } catch (e) {
      phepTon.value = 0.0;
      overtimeTon.value = 0.0;
      vacationList.clear();
    }
  }

  Future<void> loadPersonalVacation() async {
    if (getPersonalVacationUsecase == null) {
      return;
    }

    final profile = userProfile.value;
    if (profile == null) {
      return;
    }

    final hrId = profile.hrId > 0 ? profile.hrId : 1752;

    try {
      final result = await getPersonalVacationUsecase!.call(hrId: hrId);

      if (result.isSuccess && result.data != null) {
        personalVacation.value = result.data;
      } else {
        personalVacation.value = null;
      }
    } catch (e) {
      personalVacation.value = null;
    }
  }
}
