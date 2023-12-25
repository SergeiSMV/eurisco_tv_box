import 'dart:convert';
import 'dart:io' as io;

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/server_repository.dart';
import '../../domain/server_values.dart';
import 'device_implementation.dart';
import 'hive_implementation.dart';

class ServerImpl extends ServerRepository{

  final dio = Dio();

  @override // автоматическая авторизация
  Future<String> autoAuth() async {
    String result;
    Map authData = await HiveImpl().getAuthData();
    var data = jsonEncode(authData);
    
    if (authData.isEmpty){
      result = 'unlogin';
    } else {
      try{
        var responce = await dio.get(serverAuth, queryParameters: {'auth_data': data});
        result = responce.toString();
        result == 'denied' ? HiveImpl().saveAuthData({}) : null;
      } 
      on DioException catch (_){
        result = 'no connection';
      }
    }
    return result.toString();
  }
  
  @override // ручная авторизация
  Future<String> auth(Map authData) async {
    var data = jsonEncode(authData);
    String result;
    try{
      var responce = await dio.get(serverAuth, queryParameters: {'auth_data': data});
      result = responce.toString();
    } 
    on DioException catch (_){
      result = 'no connection';
    }
    result == 'admitted' ? HiveImpl().saveAuthData(authData) : null;
    return result;
  }
  
  
  @override // получить конфигурацию для TV Box
  Future<void> getAndroidConfig() async {
    // вернет => /storage/emulated/0/Android/data/com.example.promo_camera/files
    final io.Directory? directory = await getExternalStorageDirectory();
    final dir = io.Directory(directory!.path);
    final List<io.FileSystemEntity> deviceFiles = await dir.list().toList();

    // получаем deviceId из БД
    String deviceId = await DeviceImpl().getCurrentDeviceId();
    // получаем авторизационные данные из БД
    Map authData = await HiveImpl().getAuthData();

    // попытка подключения к серверу
    try{
      // запрос к серверу
      var responce = await dio.get(serverGetAndroidConfig, queryParameters: {'device_id': deviceId, 'user': authData['login']});
      // декодируем ответ от сервера
      final Map config = jsonDecode(responce.toString());

      // конфигурация контента
      List contentConfig = config[deviceId]['content'];
      // имя устройства
      String deviceName = config[deviceId]['name'];

      // скачиваем фоновое видео, если еще не скачано
      String bgPath = '${directory.path}/bg.mp4';
      bool isExistBG = await io.File(bgPath).exists();
      isExistBG ? null : await dio.download(getBGFile, bgPath);

      // если контент в конфигурации пуст
      if (contentConfig.isEmpty){
        deviceFiles.isEmpty ? null : { 
          for (var file in deviceFiles) {
            io.File(file.path).uri.pathSegments.last == 'bg.mp4' ? null : io.File(file.path).delete()
          }
        };
      } else {
        // если файлов нет на устройстве, то скачиваем
        for (var cnt in contentConfig){
          String path = '${directory.path}/${cnt['name']}';
          bool isExist = await io.File(path).exists();
          isExist ? null : await dio.download(getFile, path, queryParameters: {'user': authData['login'], 'file': cnt['name']});
        }
        // индексируем файлы на устройстве (нет в конфигурации -> удаляем с устройства)
        for (var file in deviceFiles){
          String fileName = io.File(file.path).uri.pathSegments.last;
          bool isContains = contentConfig.any((element) => element.values.contains(fileName));
          fileName == 'bg.mp4' ? null : {
            isContains ? null : deviceFiles.isEmpty ? null : io.File(file.path).delete()
          };
        }
      }

      await HiveImpl().saveConfig(contentConfig);
      await HiveImpl().saveDeviceName(deviceName);

    }
    on DioException catch (_){ }
  }



}