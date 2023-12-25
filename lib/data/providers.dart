

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'implements/device_implementation.dart';
import 'implements/hive_implementation.dart';
import 'implements/server_implementation.dart';

final onFocusIndexProvider = StateProvider((ref) {
  return 9999;
});

final configProvider = StateProvider<Map>((ref) {
  return {};
});

final loopLengthProvider = StateProvider((ref) {
  return 0;
});

final containerSizeProvider = StateProvider((ref) {
  return 0.0;
});

final contentIndexProvider = StateProvider((ref) {
  return 0;
});



final getConfigProvider = FutureProvider((ref) async {
  await ServerImpl().getAndroidConfig();
  List contentConfig = await HiveImpl().getConfig();
  String deviceName = await HiveImpl().getDeviceName();
  String deviceID = await DeviceImpl().getCurrentDeviceId();
  Map config = {'config': contentConfig, 'deviceName': deviceName, 'deviceID': deviceID};
  ref.read(configProvider.notifier).state = config;
  ref.read(loopLengthProvider.notifier).state = config['config'].length;
});