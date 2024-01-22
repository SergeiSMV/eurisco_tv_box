// главный сервер
String server = 'https://fluthon.space/develop';

// НОВЫЕ
// подключение устройства к клиенту
String serverClientConnect = '$server/box_connect';

// проверка подключения устройства к клиенту
String serverCheckDeviceConnection = '$server/check_box_connection';

// проверка подключения устройства к клиенту
String serverBoxConfig = '$server/box_config';

// отключиться от клиента
String serverDisconectDevice = '$server/box_exit';


// СТАРЫЕ
// авторизация 
String serverAuth = '$server/auth';
// запрос конфигурации для Android
String serverGetAndroidConfig = '$server/get_config_android';
// скачивание файлов
String getFile = '$server/get_media';
// скачивание файлов фонового видео
String getBGFile = '$server/get_background';