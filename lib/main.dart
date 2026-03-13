import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/config/app_config.dart';
import 'mock/mock_overrides.dart';

/// Pass `--dart-define=ENV_FILE=.env.demo` to run in demo/mock mode.
const _envFile = String.fromEnvironment('ENV_FILE', defaultValue: '.env');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: _envFile);

  // Always initialize Supabase (even in mock mode) so SupabaseConfig.client
  // is available for service class constructors. Mock overrides ensure no
  // real network calls are made.
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder_key',
  );

  final overrides = AppConfig.isMockMode ? MockOverrides.all : <Override>[];

  runApp(ProviderScope(overrides: overrides, child: const HrisApp()));
}
