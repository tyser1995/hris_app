import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/router/app_router.dart';
import 'core/constants/app_strings.dart';
import 'providers/settings_provider.dart';

class HrisApp extends ConsumerWidget {
  const HrisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(appThemeProvider);
    final settings = ref.watch(companySettingsProvider).valueOrNull;

    return MaterialApp.router(
      title: settings?.systemTitle ?? AppStrings.appFullName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: theme,
    );
  }
}
