

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




  // СТАРЫЕ
  @override // получить логин / пароль
  Future<Map> getAuthData() async {
    Map authData = await hive.get('authData', defaultValue: {});
    return authData;
  }
  
  @override // получить ссылки файлов
  Future<List> getConfig() async {
    List currentConfig = await hive.get('config', defaultValue: []);
    return currentConfig;
  }
  
  
  
  @override // сохранить логин / пароль
  Future<void> saveAuthData(Map authData) async {
    await hive.put('authData', authData);
  }
  
  @override // сохраняем ссылки файлов
  Future<void> saveConfig(List config) async {
    await hive.put('config', config);
  }
  
  
  
  
}