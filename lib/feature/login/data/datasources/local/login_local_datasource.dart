import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/feature/login/data/models/google_user_dto.dart';

abstract class LoginLocalDataSource {
  Future<void> saveUser(GoogleUserDto user);
  Future<GoogleUserDto?> getUser();
  Future<void> clearUser();
}

class LoginLocalDataSourceImpl implements LoginLocalDataSource {
  static const String _boxName = 'google_user_box';
  static const String _userKey = 'current_user';

  @override
  Future<void> saveUser(GoogleUserDto user) async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    final box = Hive.box(_boxName);
    await box.put(_userKey, user.toJson());
  }

  @override
  Future<GoogleUserDto?> getUser() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    final box = Hive.box(_boxName);
    final userData = box.get(_userKey);
    if (userData == null) return null;
    return GoogleUserDto.fromJson(
      Map<String, dynamic>.from(userData),
    );
  }

  @override
  Future<void> clearUser() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    final box = Hive.box(_boxName);
    await box.delete(_userKey);
  }
}

