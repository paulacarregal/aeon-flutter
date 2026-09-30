
class AppConfig {
  static const String backendUrl =
    'https://aeon-backend-deploy.onrender.com';

  static const String openWeatherKey =
      String.fromEnvironment('OPENWEATHER_KEY', defaultValue: '');

  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  static const String defaultCity = 'Sao Paulo';


  static const String zabbixHost =
      String.fromEnvironment('ZABBIX_HOST', defaultValue: '');

  static const int zabbixPort =
      int.fromEnvironment('ZABBIX_PORT', defaultValue: 10051);

  
  static const String zabbixAppHost = 'aeon-flutter';
  
}
