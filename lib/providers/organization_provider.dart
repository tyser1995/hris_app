import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/organization_model.dart';
import '../services/organization_service.dart';

final organizationServiceProvider =
    Provider<OrganizationService>((_) => OrganizationService());

/// All organizations — super_admin only.
final organizationsProvider =
    FutureProvider<List<OrganizationModel>>((ref) async {
  return ref.read(organizationServiceProvider).getOrganizations();
});
