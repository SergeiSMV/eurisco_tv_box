



import 'package:dart_amqp/dart_amqp.dart' as ampq;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/implements/rabbitmq_implementation.dart';
import '../data/providers.dart';
import '../globals.dart';
import 'appbar.dart';
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

  @override
  void initState() {
    super.initState();
    return ref.refresh(getConfigProvider);
  }

  @override
  void dispose() async {
    client?.close();
    super.dispose();
  }

  Future rabbitInit(BuildContext context) async {
    client = await RabbitMQImpl().connectToRabbitMQ(context, ref);
  }
  

  @override
  Widget build(BuildContext context) {

    rabbitInit(context);

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select) : const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActionIntent: CallbackAction(onInvoke: (Intent i) => null),
        },
        child: WillPopScope(
          onWillPop: () async {
            return false;
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
                  return content.isEmpty ?
                  const DemoMode(title: '',) : 
                  Stack(
                    children: [
                      ContentManager(allContents: content),
                      appBar(context)
                    ],
                  );
                }
              ),
            ),
          ),
        ),
      ),
    );
  }
}