
abstract class ServerRepository{

  // НОВЫЕ
  // подключение устройства к клиенту
  Future<String> connectDevice(String pin, screenWidth, screenHeight);

  // проверка подключения устройства к клиенту
  Future<String> checkDeviceConnection();

  // получить конфигурацию для TV Box
  Future<List> getBoxConfig(int screenWidth, int screenHeight);

  // отключиться от клиента
  Future<void> disconectDevice();

}