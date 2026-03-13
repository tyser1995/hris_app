import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/employee_service.dart';
import '../models/employee_model.dart';

final employeeServiceProvider =
    Provider<EmployeeService>((ref) => EmployeeService());

final employeeListProvider = FutureProvider.family<List<EmployeeModel>,
    ({int page, String? search, String? departmentId, String? employmentType})>(
  (ref, params) => ref.watch(employeeServiceProvider).getEmployees(
        page: params.page,
        search: params.search,
        departmentId: params.departmentId,
        employmentType: params.employmentType,
      ),
);

final employeeDetailProvider =
    FutureProvider.family<EmployeeModel?, String>((ref, id) {
  return ref.watch(employeeServiceProvider).getEmployee(id);
});

final employeeCountProvider = FutureProvider<int>((ref) {
  return ref.watch(employeeServiceProvider).getTotalCount();
});

final expiringContractsProvider =
    FutureProvider<List<EmployeeModel>>((ref) {
  return ref.watch(employeeServiceProvider).getExpiringContracts();
});

// Notifier for employee list with filter state
class EmployeeFilterState {
  final String? search;
  final String? departmentId;
  final String? employmentType;
  final int page;

  const EmployeeFilterState({
    this.search,
    this.departmentId,
    this.employmentType,
    this.page = 0,
  });

  EmployeeFilterState copyWith({
    String? search,
    String? departmentId,
    String? employmentType,
    int? page,
  }) =>
      EmployeeFilterState(
        search: search ?? this.search,
        departmentId: departmentId ?? this.departmentId,
        employmentType: employmentType ?? this.employmentType,
        page: page ?? this.page,
      );
}

class EmployeeFilterNotifier extends Notifier<EmployeeFilterState> {
  @override
  EmployeeFilterState build() => const EmployeeFilterState();

  void setSearch(String? value) =>
      state = state.copyWith(search: value, page: 0);
  void setDepartment(String? id) =>
      state = state.copyWith(departmentId: id, page: 0);
  void setEmploymentType(String? type) =>
      state = state.copyWith(employmentType: type, page: 0);
  void nextPage() => state = state.copyWith(page: state.page + 1);
  void prevPage() {
    if (state.page > 0) state = state.copyWith(page: state.page - 1);
  }

  void reset() => state = const EmployeeFilterState();
}

final employeeFilterProvider =
    NotifierProvider<EmployeeFilterNotifier, EmployeeFilterState>(
  EmployeeFilterNotifier.new,
);
