import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart' as amqp;
import 'package:eurisco_tv_box/domain/rabbitmq_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../globals.dart';
import '../../presentation/auth.dart';
import '../providers.dart';
import 'device_implementation.dart';

class RabbitMQImpl extends RabbitMQRepository{

  //подключаемся к серверу RabbitMQ
  @override
  Future connectToRabbitMQ(BuildContext context, WidgetRef ref) async {
    amqp.Client client = amqp.Client();
    String deviceID = await DeviceImpl().getCurrentDeviceId();
    try {
      client = amqp.Client(
        settings: amqp.ConnectionSettings(
          host: '89.104.65.133',
          authProvider: const amqp.PlainAuthenticator('rabbit', '2001'),
        ),
      );

      amqp.Channel channel = await client.channel();
      amqp.Queue queue = await channel.queue('euriscotv_qu', durable: true);

      amqp.Consumer consumer = await queue.consume(noAck: false);
      consumer.listen((amqp.AmqpMessage message) {
        Map result = jsonDecode(message.payloadAsString);
        result['action'] == 'update' ? {
          ref.read(contentForDisplayProvider.notifier).state = [],
          ref.read(contentIndexProvider.notifier).state = 0,
          ref.refresh(getConfigProvider)
        } : null;

        result['action'] == 'exit' && result['device'] == deviceID ? {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Auth())),
          ref.read(contentForDisplayProvider.notifier).state = [],
          ref.read(contentIndexProvider.notifier).state = 0,
          DeviceImpl().deleteAllContents(),
          client.close()
        } : null;

        // Подтверждение обработки сообщения
        message.ack();
      });
    } catch (e) {
      null;
    }
    return client;
  } 



}