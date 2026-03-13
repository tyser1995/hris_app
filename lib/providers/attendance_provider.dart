import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_service.dart';
import '../models/attendance_model.dart';

final attendanceServiceProvider =
    Provider<AttendanceService>((ref) => AttendanceService());

final todayAttendanceStreamProvider =
    StreamProvider<List<AttendanceModel>>((ref) {
  return ref.watch(attendanceServiceProvider).streamTodayAttendance();
});

final attendanceByDateProvider =
    FutureProvider.family<List<AttendanceModel>, DateTime>((ref, date) {
  return ref.watch(attendanceServiceProvider).getAttendanceByDate(date);
});

final employeeAttendanceProvider = FutureProvider.family<List<AttendanceModel>,
    ({String employeeId, DateTime startDate, DateTime endDate})>(
  (ref, params) => ref
      .watch(attendanceServiceProvider)
      .getEmployeeAttendance(
        params.employeeId,
        startDate: params.startDate,
        endDate: params.endDate,
      ),
);

final myTodayAttendanceProvider =
    FutureProvider.family<AttendanceModel?, String>((ref, employeeId) {
  return ref.watch(attendanceServiceProvider).getTodayAttendance(employeeId);
});
