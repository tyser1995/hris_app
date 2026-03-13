import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  /// True when the app is running in demo/mock mode (MOCK_DATA=true in .env).
  static bool get isMockMode =>
      dotenv.env['MOCK_DATA']?.toLowerCase() == 'true';
}
