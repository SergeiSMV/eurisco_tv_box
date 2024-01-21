

abstract class HiveRepository{

  // НОВЫЕ
  // сохранить клиента, которому принадлежит устройство
  Future<void> saveClient(String client);

  // получить клиента, которому принадлежит устройство
  Future<String> getClient();


  // СТАРЫЕ
  // сохранить логин / пароль
  Future<void> saveAuthData(Map authData);

  // получить логин / пароль
  Future<Map> getAuthData();

  //сохраняем ссылки файлов
  Future<void> saveConfig(List config);

  //сохраняем имя устройства
  Future<void> saveDeviceName(String name);

  //получить ссылки файлов
  Future<List> getConfig();

  //получить имя устройства
  Future<String> getDeviceName();

}