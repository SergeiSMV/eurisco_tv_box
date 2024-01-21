

import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/hive_repository.dart';

class HiveImpl extends HiveRepository{

  final Box hive = Hive.box('hiveStorage');


  // НОВЫЕ
  @override // сохранить логин / пароль
  Future<void> saveClient(String client) async {
    await hive.put('client', client);
  }

  @override // сохранить логин / пароль
  Future<String> getClient() async {
    String client = await hive.get('client', defaultValue: '');
    return client;
  }

  @override // получить имя устройства
  Future<String> getDeviceName() async {
    String deviceName = await hive.get('deviceName', defaultValue: '');
    return deviceName;
  }

  @override // сохраняем имя устройства
  Future<void> saveDeviceName(String name) async {
    await hive.put('deviceName', name);
  }
  
}