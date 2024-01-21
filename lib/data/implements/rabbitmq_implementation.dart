import 'dart:convert';

import 'package:dart_amqp/dart_amqp.dart' as amqp;
import 'package:eurisco_tv_box/domain/rabbitmq_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

class RabbitMQImpl extends RabbitMQRepository{

  //подключаемся к серверу RabbitMQ
  @override
  Future connectToRabbitMQ(WidgetRef ref) async {
    amqp.Client client = amqp.Client();
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
        // Подтверждение обработки сообщения
        message.ack();
      });
    } catch (e) {
      null;
    }
    return client;
  } 



}