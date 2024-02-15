import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'implements/device_implementation.dart';
import 'implements/hive_implementation.dart';
import 'implements/server_implementation.dart';


// РАБОТА С КОНФИГУРАЦИЕЙ

final contentProvider = StateProvider<List>((ref) {
  return [];
});

final contentForDisplayProvider = StateProvider<List>((ref) {
  return [];
});

final contentIndexProvider = StateProvider((ref) {
  return 0;
});

final configProvider = StateProvider<Map>((ref) {
  return {};
});


final getConfigProvider = FutureProvider.family((ref, Map<String, dynamic> screen) async {
  List result = await ServerImpl().getBoxConfig(screen['width'], screen['height']);
  // log.d(result);
  String deviceName = await HiveImpl().getDeviceName();
  String deviceID = await DeviceImpl().getCurrentDeviceId();
  Map config = {'content': result, 'deviceName': deviceName, 'deviceID': deviceID};
  ref.read(contentProvider.notifier).state = result;
  ref.read(configProvider.notifier).state = config;
});


// ПРОЧИЕ ПРОВАЙДЕРЫ

// ContentLib
final onFocusIndexProvider = StateProvider((ref) {
  return 9999;
});

// appBar
final containerSizeProvider = StateProvider((ref) {
  return 0.0;
});