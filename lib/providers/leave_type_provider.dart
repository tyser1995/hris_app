import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/leave_type_service.dart';
import '../models/leave_type_model.dart';

final leaveTypeServiceProvider =
    Provider<LeaveTypeService>((_) => LeaveTypeService());

final leaveTypesProvider =
    FutureProvider.autoDispose<List<LeaveTypeModel>>((ref) {
  return ref.read(leaveTypeServiceProvider).getLeaveTypes();
});
