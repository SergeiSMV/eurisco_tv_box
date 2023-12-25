import 'package:android_id/android_id.dart';
import 'package:flutter/services.dart';

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

}