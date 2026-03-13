import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/department_service.dart';
import '../models/department_model.dart';
import '../models/position_model.dart';

final departmentServiceProvider =
    Provider<DepartmentService>((ref) => DepartmentService());

final departmentListProvider =
    FutureProvider<List<DepartmentModel>>((ref) {
  return ref.watch(departmentServiceProvider).getDepartments();
});

final positionListProvider =
    FutureProvider.family<List<PositionModel>, String?>((ref, departmentId) {
  return ref
      .watch(departmentServiceProvider)
      .getPositions(departmentId: departmentId);
});
