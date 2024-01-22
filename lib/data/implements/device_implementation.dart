import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/device_repository.dart';

class DeviceImpl extends DeviceRepository{
  
  //получаем данные о девайсе
  @override
  Future<String> getCurrentDeviceId() async {
    String deviceId;
    const androidIdPlugin = AndroidId();
    try {
      deviceId = await androidIdPlugin.getId() ?? 'Unknown ID';
    } on PlatformException {
      deviceId = 'Failed';
    }
    return deviceId;
  }

  // удаляем весь контент с устройства
  @override
  Future<void> deleteAllContents() async {
    final Directory? directory = await getExternalStorageDirectory();
    final dir = Directory(directory!.path);
    final List<FileSystemEntity> deviceFiles = await dir.list().toList();

    for (var file in deviceFiles) {
      File(file.path).delete();
    }
  }

}