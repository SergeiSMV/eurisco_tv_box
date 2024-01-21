
abstract class ServerRepository{

  // НОВЫЕ
  // подключение устройства к клиенту
  Future<String> connectDevice(String pin);

  // проверка подключения устройства к клиенту
  Future<String> checkDeviceConnection();

  // получить конфигурацию для TV Box
  Future<List> getBoxConfig();

}