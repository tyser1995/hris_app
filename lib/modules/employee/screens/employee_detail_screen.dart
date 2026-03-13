import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/employee_provider.dart';
import '../../../models/employee_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';

class EmployeeDetailScreen extends ConsumerWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailProvider(employeeId));
    final isAdminOrHr = ref.watch(isAdminOrHrProvider);

    return employeeAsync.when(
      loading: () =>
          const Scaffold(body: HrisLoadingWidget()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: HrisErrorWidget(message: e.toString()),
      ),
      data: (employee) {
        if (employee == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const HrisEmptyWidget(message: 'Employee not found'),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(employee.fullName),
            actions: [
              if (isAdminOrHr)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      context.go('/employees/$employeeId/edit'),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor:
                            AppColors.primaryLight.withOpacity(0.2),
                        backgroundImage: employee.avatarUrl != null
                            ? NetworkImage(employee.avatarUrl!)
                            : null,
                        child: employee.avatarUrl == null
                            ? Text(
                                '${employee.firstName[0]}${employee.lastName[0]}',
                                style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        employee.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        employee.positionTitle ?? 'No position',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      Text(
                        employee.departmentName ?? 'No department',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(employee.employmentType
                            .toUpperCase()
                            .replaceAll('_', ' ')),
                        backgroundColor:
                            AppColors.primary.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Employment info
                _Section(
                  title: 'Employment Information',
                  children: [
                    _InfoRow('Employee Code', employee.employeeCode),
                    _InfoRow('Status',
                        employee.employmentStatus.toUpperCase()),
                    _InfoRow('Hire Date',
                        HrisDateUtils.toDisplay(employee.hireDate)),
                    if (employee.contractStart != null)
                      _InfoRow('Contract Start',
                          HrisDateUtils.toDisplay(employee.contractStart!)),
                    if (employee.contractEnd != null)
                      _InfoRow(
                        'Contract End',
                        HrisDateUtils.toDisplay(employee.contractEnd!),
                        valueColor: employee.isContractExpiringSoon
                            ? AppColors.warning
                            : null,
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Personal info
                _Section(
                  title: 'Personal Information',
                  children: [
                    _InfoRow('Email', employee.email),
                    if (employee.phone != null)
                      _InfoRow('Phone', employee.phone!),
                    if (employee.address != null)
                      _InfoRow('Address', employee.address!),
                    if (employee.birthdate != null)
                      _InfoRow('Birthdate',
                          HrisDateUtils.toDisplay(employee.birthdate!)),
                    if (employee.civilStatus != null)
                      _InfoRow('Civil Status',
                          employee.civilStatus!.toUpperCase()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary)),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
