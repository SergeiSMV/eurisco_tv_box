

import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class RabbitMQRepository{

  //подключаемся к серверу RabbitMQ
  Future connectToRabbitMQ(WidgetRef ref);

}