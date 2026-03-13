import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/leave_service.dart';
import '../models/leave_request_model.dart';

final leaveServiceProvider =
    Provider<LeaveService>((ref) => LeaveService());

final leaveListProvider = FutureProvider.family<List<LeaveRequestModel>,
    ({String? employeeId, String? status, int page})>(
  (ref, params) => ref.watch(leaveServiceProvider).getLeaveRequests(
        employeeId: params.employeeId,
        status: params.status,
        page: params.page,
      ),
);

final leaveBalancesProvider =
    FutureProvider.family<Map<String, double>, ({String employeeId, int year})>(
  (ref, params) => ref
      .watch(leaveServiceProvider)
      .getLeaveBalances(params.employeeId, params.year),
);

final pendingLeaveCountProvider = FutureProvider<int>((ref) async {
  final leaves = await ref
      .watch(leaveServiceProvider)
      .getLeaveRequests(status: 'pending_supervisor');
  return leaves.length;
});
