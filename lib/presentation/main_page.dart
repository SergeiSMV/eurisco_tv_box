import 'dart:async';
import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart' as ampq;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../data/implements/device_implementation.dart';
import '../data/implements/rabbitmq_implementation.dart';
import '../data/providers.dart';
import 'appbar.dart';
import 'auth.dart';
import 'player/content_manager.dart';
import 'player/demo_mode.dart';

class ActionIntent extends Intent {}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {

  ampq.Client? client;
  ampq.Channel? channel;
  ampq.Queue? queue;
  ampq.Consumer? consumer;
  Timer? connectMonitoring;
  late String deviceID;



  @override
  void initState() {
    super.initState();
    rabbitInit();
    return ref.refresh(getConfigProvider);
  }

  @override
  void dispose() {
    client?.close();
    WakelockPlus.disable();
    super.dispose();
  }

  Future rabbitInit() async {
    deviceID = await DeviceImpl().getCurrentDeviceId();
    await RabbitMQImpl().connectToRabbitMQ().then((initClient) async {
      client = initClient;
      channel = await client!.channel();
      queue = await channel!.queue('euriscotv_qu', durable: true);
      consumer = await queue!.consume(noAck: false);
      RabbitMQImpl().listener(consumer!, messageProcessing);
    });
    scheduleConnect(queue!);
    WakelockPlus.enable();
  }

  void scheduleConnect(ampq.Queue queue) {
    if (connectMonitoring != null) {
      connectMonitoring!.cancel();
    }
    connectMonitoring = Timer(const Duration(seconds: 180), () {
      queue.publish('test_connection');
      scheduleConnect(queue);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select) : const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActionIntent: CallbackAction(onInvoke: (Intent i) => null),
        },
        child: GestureDetector(
          onPanUpdate: (details) async {
            ref.read(contentForDisplayProvider.notifier).state = [];
            ref.read(contentIndexProvider.notifier).state = 0;
            return ref.refresh(getConfigProvider);
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Consumer(
              builder: (context, ref, child) {
                List content = ref.watch(contentProvider);
                // Map deviceConfig = ref.read(configProvider);
                return content.isEmpty ?
                const DemoMode(title: '',) : ContentManager(allContents: content);
                /*
                Stack(
                  children: [
                    ContentManager(allContents: content),
                    appBar(context, deviceConfig)
                  ],
                );
                */
              }
            ),
          ),
        ),
      ),
    );
  }

  void messageProcessing(String message) {
    try{
      Map result = jsonDecode(message);
      result['action'] == 'update' && result['device'] == deviceID ? {
        ref.read(contentForDisplayProvider.notifier).state = [],
        ref.read(contentIndexProvider.notifier).state = 0,
        ref.refresh(getConfigProvider)
      } : null;

      result['action'] == 'exit' && result['device'] == deviceID ? {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Auth())),
        ref.read(contentForDisplayProvider.notifier).state = [],
        ref.read(contentIndexProvider.notifier).state = 0,
        DeviceImpl().deleteAllContents(),
        client?.close()
      } : null;
    } catch (e) {
      null;
    }
  }

}