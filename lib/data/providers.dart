

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../globals.dart';
import 'implements/device_implementation.dart';
import 'implements/hive_implementation.dart';
import 'implements/server_implementation.dart';

final onFocusIndexProvider = StateProvider((ref) {
  return 9999;
});

final configProvider = StateProvider<Map>((ref) {
  return {};
});

final contentForDisplayProvider = StateProvider<List>((ref) {
  return [];
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
  log.d('получено указание на обновление');
  List result = await ServerImpl().getBoxConfig();
  String deviceName = await HiveImpl().getDeviceName();
  String deviceID = await DeviceImpl().getCurrentDeviceId();
  Map config = {'content': result, 'deviceName': deviceName, 'deviceID': deviceID};
  ref.read(loopLengthProvider.notifier).state = result.length;
  ref.read(configProvider.notifier).state = config;
});