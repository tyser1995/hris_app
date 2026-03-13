import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company_settings_model.dart';
import '../services/settings_service.dart';

final settingsServiceProvider = Provider<SettingsService>((_) => SettingsService());

final companySettingsProvider = FutureProvider<CompanySettingsModel>((ref) {
  return ref.read(settingsServiceProvider).getSettings();
});
