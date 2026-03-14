import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase/supabase_config.dart';
import '../core/constants/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../models/company_settings_model.dart';
import '../providers/auth_provider.dart';
import '../services/settings_service.dart';

final settingsServiceProvider =
    Provider<SettingsService>((_) => SettingsService());

final companySettingsProvider = FutureProvider<CompanySettingsModel>((ref) {
  // Re-fetch whenever the logged-in user changes so each account sees its
  // own organization's branding instead of a previous user's cached data.
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.session?.user.id;
  if (userId == null) return CompanySettingsModel.defaults;
  return ref.read(settingsServiceProvider).getSettings();
});

/// Subscribes to Supabase Realtime UPDATE events on `hris.organizations`.
///
/// When any admin in the organization saves branding or settings changes,
/// the DB row is updated and this subscription fires — invalidating
/// [companySettingsProvider] so every connected user re-fetches the latest
/// settings automatically (sidebar title, primary color, logo, etc.).
///
/// Watch this provider from [AdminShell] to keep it alive for the whole session.
final orgSettingsRealtimeProvider = Provider.autoDispose<void>((ref) {
  final client = SupabaseConfig.client;

  final channel = client
      .channel('org-settings-sync')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'hris',
        table: 'organizations',
        callback: (_) {
          // Re-fetch settings for this user — RLS ensures they get their own org.
          ref.invalidate(companySettingsProvider);
        },
      )
      .subscribe();

  ref.onDispose(() => client.removeChannel(channel));
});

/// Dynamic [ThemeData] derived from the stored primary color.
/// Falls back to [AppColors.primary] while settings are loading or on error.
final appThemeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(companySettingsProvider).valueOrNull;
  final primaryColor =
      parseHexColor(settings?.primaryColor) ?? AppColors.primary;
  return buildAppTheme(primaryColor);
});
