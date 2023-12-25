
abstract class ServerRepository{

  // автоматическая авторизация
  Future<String> autoAuth();

  // ручная авторизация
  Future<String> auth(Map authData);

  // получить конфигурацию android
  Future<void> getAndroidConfig();

}