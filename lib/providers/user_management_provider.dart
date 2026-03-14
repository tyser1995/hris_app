import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/org_user_model.dart';
import '../services/user_management_service.dart';

final userManagementServiceProvider =
    Provider<UserManagementService>((_) => UserManagementService());

final orgUsersProvider = FutureProvider<List<OrgUserModel>>((ref) {
  return ref.read(userManagementServiceProvider).getOrgUsers();
});
