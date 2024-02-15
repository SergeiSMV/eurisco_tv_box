import 'dart:convert';
import 'dart:io' as io;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/server_repository.dart';
import '../../domain/server_values.dart';
import '../../globals.dart';
import 'device_implementation.dart';
import 'hive_implementation.dart';

class ServerImpl extends ServerRepository{

  final dio = Dio();

  // НОВЫЕ
  @override // подключение устройства к клиенту
  Future<String> connectDevice(String pin, screenWidth, screenHeight) async {
    String result;
    String deviceID = await DeviceImpl().getCurrentDeviceId();
    try{
      var responce = await dio.get(serverClientConnect, queryParameters: {'device_id': deviceID, 'pin': pin, 'screen_width': screenWidth, 'screen_height': screenHeight});
      responce.data.toString() == 'failed' ? {
        result = 'не верный PIN код'
      } : {
        result = 'устройство успешно подключено',
        HiveImpl().saveClient(responce.data.toString())
      };
    } 
    on DioException catch (_){
      result = 'невозможно подключиться к серверу';
    }
    return result;
  }


  @override // проверка подключения устройства к клиенту
  Future<String> checkDeviceConnection() async {
    String result;
    String deviceID = await DeviceImpl().getCurrentDeviceId();
    String client = await HiveImpl().getClient();
    if (client.isEmpty){
      result = 'disconnect';
    } else {
      try{
        var responce = await dio.get(serverCheckDeviceConnection, queryParameters: {'device_id': deviceID, 'client': client});
        result = responce.data.toString();
      } 
      on DioException catch (_){
        result = 'serverError';
      }
    }
    return result;
  }


  @override // получить конфигурацию для TV Box
  Future<List> getBoxConfig(int screenWidth, int screenHeight) async {
    List boxConfig = [];
    // вернет => /storage/emulated/0/Android/data/com.example.promo_camera/files
    final io.Directory? directory = await getExternalStorageDirectory();
    final dir = io.Directory(directory!.path);
    final List<io.FileSystemEntity> deviceFiles = await dir.list().toList();

    String deviceId = await DeviceImpl().getCurrentDeviceId();
    String client = await HiveImpl().getClient();

    try{
      var responce = await dio.get(serverBoxConfig, queryParameters: {'device_id': deviceId, 'client': client});
      var result = jsonDecode(responce.toString());

      log.d(result);

      Map contentConfig = result['content'];
      String deviceName = result['name'];

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
        for (var conf in contentConfig.entries){
          String path = '${directory.path}/${conf.key}';
          bool isExist = await io.File(path).exists();
          
          // isExist ? null : await dio.download(conf.value['stream'], path);

          if(isExist){
            null;
          } else {
            String filename = conf.value['stream'].split('/').last.toString();
            String extension = filename.split('.').last.toString();
            
            if(extension == 'jpg'){
              await dio.download(conf.value['stream'], path);
              final tempDir = await getTemporaryDirectory();
              final tempPath = tempDir.path;

              final targetPath = '$tempPath/$filename';
              // Сжатие изображения и сохранение результата во временный файл
              final result = await FlutterImageCompress.compressAndGetFile(
                path,
                targetPath,
                minWidth: screenWidth,
                // minHeight: screenHeight,
                quality: 80,
              );

              if (result != null) {
                await File(path).writeAsBytes(await result.readAsBytes());
                io.File(targetPath).delete();
              }
            } else {
              await dio.download(conf.value['stream'], path);
            }
          }

          Map currentContent = Map.from(conf.value);
          currentContent['name'] = conf.key;
          boxConfig.add(currentContent);
        }
      }
      
      // индексируем файлы на устройстве (нет в конфигурации -> удаляем с устройства)
      for (var file in deviceFiles){
        String fileName = io.File(file.path).uri.pathSegments.last;
        bool isContains = contentConfig.containsKey(fileName);
        if(fileName == 'bg.mp4'){
          continue;
        } else {
          if(await io.File(file.path).exists()){
            isContains ? null : io.File(file.path).delete();
          }
        }
      }

      await HiveImpl().saveDeviceName(deviceName);

    }
    on DioException catch (_){ }
    return boxConfig;
  }

  @override // отключиться от клиента
  Future<void> disconectDevice() async {
    String deviceID = await DeviceImpl().getCurrentDeviceId();
    String client = await HiveImpl().getClient();
    try{
      await dio.get(serverDisconectDevice, queryParameters: {'device_id': deviceID, 'client': client});
    } 
    on DioException catch (_){
      null;
    }
  }

}