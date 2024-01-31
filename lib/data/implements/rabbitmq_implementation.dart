import 'dart:async';

import 'package:dart_amqp/dart_amqp.dart';
import 'package:eurisco_tv_box/domain/rabbitmq_repository.dart';

class RabbitMQImpl extends RabbitMQRepository{

  // подключаемся к серверу RabbitMQ
  @override
  Future<Client> connectToRabbitMQ() async {
    try {
      Client client = Client();
      client = Client(
        settings: ConnectionSettings(
          host: '89.104.65.133',
          authProvider: const PlainAuthenticator('rabbit', '2001'),
        ),
      );
      return client;
    } catch (e) {
      await Future.delayed(const Duration(seconds: 10)); // Задержка перед повторной попыткой
      return connectToRabbitMQ();
    }
  }

  // слушаем сервер RabbitMQ
  @override
  void listener(Consumer consumer, Function messageProcessing) {
    consumer.listen((message) {
      // Подтверждение обработки сообщения
      message.ack();
      messageProcessing(message.payloadAsString);
    });
  }



}