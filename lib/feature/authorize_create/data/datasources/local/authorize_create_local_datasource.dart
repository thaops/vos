import 'package:hive_flutter/hive_flutter.dart';
import 'package:vos_flutter/feature/authorize_create/data/models/authorize_create_dto.dart';

abstract class AuthorizeCreateLocalDataSource {
  Future<void> saveAuthorizeCreate(AuthorizeCreateDto item);
  Future<AuthorizeCreateDto?> getAuthorizeCreate(String id);
  Future<void> clearAuthorizeCreate(String id);
  Future<void> clearAllAuthorizeCreate();

  Future<void> saveAuthorizeCreateList(List<AuthorizeCreateDto> items);
  Future<List<AuthorizeCreateDto>> getAuthorizeCreateList();
  Future<void> clearAuthorizeCreateList();

  
}

class AuthorizeCreateLocalDataSourceImpl
    implements AuthorizeCreateLocalDataSource {
  static const String _boxName = 'authorize_create_box';
  static const String _listKey = 'authorize_create_list';
  

  Future<Box> _ensureBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  @override
  Future<void> saveAuthorizeCreate(AuthorizeCreateDto item) async {
    final box = await _ensureBox();
    await box.put('authorize_create_${item.id}', item.toJson());
  }

  @override
  Future<AuthorizeCreateDto?> getAuthorizeCreate(String id) async {
    final box = await _ensureBox();
    final data = box.get('authorize_create_$id');
    if (data == null) return null;
    return AuthorizeCreateDto.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<void> clearAuthorizeCreate(String id) async {
    final box = await _ensureBox();
    await box.delete('authorize_create_$id');
  }

  @override
  Future<void> clearAllAuthorizeCreate() async {
    final box = await _ensureBox();
    final keys =
        box.keys.where((key) => key.toString().startsWith('authorize_create_')).toList();
    for (final key in keys) {
      await box.delete(key);
    }
    await box.delete(_listKey);
    
  }

  @override
  Future<void> saveAuthorizeCreateList(
    List<AuthorizeCreateDto> items,
  ) async {
    final box = await _ensureBox();
    final listData = items.map((item) => item.toJson()).toList();
    await box.put(_listKey, listData);
    for (final item in items) {
      await box.put('authorize_create_${item.id}', item.toJson());
    }
  }

  @override
  Future<List<AuthorizeCreateDto>> getAuthorizeCreateList() async {
    final box = await _ensureBox();
    final listData = box.get(_listKey);
    if (listData is List) {
      return listData
          .map(
            (item) => AuthorizeCreateDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    }
    return [];
  }

  @override
  Future<void> clearAuthorizeCreateList() async {
    final box = await _ensureBox();
    await box.delete(_listKey);
  }

  
}

