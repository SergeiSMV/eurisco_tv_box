

import 'package:dart_amqp/dart_amqp.dart';

abstract class RabbitMQRepository{

  //подключаемся к серверу RabbitMQ
  Future connectToRabbitMQ();

  // слушаем сервер RabbitMQ
  void listener(Consumer consumer, Function messageProcessing);

}