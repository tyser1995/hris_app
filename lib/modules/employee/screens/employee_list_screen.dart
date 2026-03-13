import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/employee_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_filter_bar.dart';

class EmployeeListScreen extends ConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(employeeFilterProvider);
    final employeesAsync = ref.watch(
      employeeListProvider((
        page: filter.page,
        search: filter.search,
        departmentId: filter.departmentId,
        employmentType: filter.employmentType,
      )),
    );
    final isAdminOrHr = ref.watch(isAdminOrHrProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(AppStrings.employees),
        actions: [
          if (isAdminOrHr)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: () => context.go('/employees/new'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.person_add_rounded, size: 16),
                label: const Text(
                  'Add',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            color: AppColors.surfaceLight,
            child: EmployeeFilterBar(
              onSearch: (v) =>
                  ref.read(employeeFilterProvider.notifier).setSearch(v),
              onDepartmentFilter: (id) =>
                  ref.read(employeeFilterProvider.notifier).setDepartment(id),
              onTypeFilter: (type) =>
                  ref.read(employeeFilterProvider.notifier).setEmploymentType(type),
            ),
          ),
          const Divider(height: 1),

          // Employee list
          Expanded(
            child: employeesAsync.when(
              loading: () => const HrisLoadingWidget(message: 'Loading employees...'),
              error: (e, _) => HrisErrorWidget(
                message: e.toString(),
                onRetry: () => ref.invalidate(employeeListProvider),
              ),
              data: (employees) {
                if (employees.isEmpty) {
                  return const HrisEmptyWidget(
                    message: 'No employees match your search',
                    icon: Icons.people_outline_rounded,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: employees.length,
                  itemBuilder: (_, i) => EmployeeCard(
                    employee: employees[i],
                    onTap: () =>
                        context.go('/employees/${employees[i].id}'),
                  ),
                );
              },
            ),
          ),

          // Pagination
          _PaginationBar(filter: filter, ref: ref),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  final dynamic filter;
  final WidgetRef ref;

  const _PaginationBar({required this.filter, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            label: const Text('Previous'),
            style: TextButton.styleFrom(
              foregroundColor: filter.page > 0
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
            onPressed: filter.page > 0
                ? () => ref.read(employeeFilterProvider.notifier).prevPage()
                : null,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Page ${filter.page + 1}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            label: const Text('Next'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            onPressed: () =>
                ref.read(employeeFilterProvider.notifier).nextPage(),
          ),
        ],
      ),
    );
  }
}
