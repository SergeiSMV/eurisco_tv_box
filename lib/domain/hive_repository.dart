

abstract class HiveRepository{

  // НОВЫЕ
  // сохранить клиента, которому принадлежит устройство
  Future<void> saveClient(String client);

  // получить клиента, которому принадлежит устройство
  Future<String> getClient();

  //сохраняем имя устройства
  Future<void> saveDeviceName(String name);


  // получить имя устройства
  Future<String> getDeviceName();

}