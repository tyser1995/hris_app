import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/department_provider.dart';
import '../../../services/report_service.dart';
import '../../../shared/widgets/loading_overlay.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String? _selectedDeptId;
  bool _isLoading = false;
  List<Map<String, dynamic>>? _payrollData;

  Future<void> _exportPayroll() async {
    setState(() {
      _isLoading = true;
      _payrollData = null;
    });

    try {
      final result = await ReportService().exportPayroll(
        year: _selectedYear,
        month: _selectedMonth,
        departmentId: _selectedDeptId,
      );
      setState(() {
        _payrollData =
            List<Map<String, dynamic>>.from(result['data'] as List);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentListProvider);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.reports)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report type cards
              Text(
                'Available Reports',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount:
                    MediaQuery.of(context).size.width > 600 ? 3 : 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: const [
                  _ReportCard(
                    icon: Icons.calendar_today,
                    label: 'Daily Attendance',
                    color: AppColors.primary,
                  ),
                  _ReportCard(
                    icon: Icons.date_range,
                    label: 'Monthly Attendance',
                    color: AppColors.secondary,
                  ),
                  _ReportCard(
                    icon: Icons.schedule,
                    label: 'Late Employees',
                    color: AppColors.statusLate,
                  ),
                  _ReportCard(
                    icon: Icons.people,
                    label: 'Employee List',
                    color: AppColors.info,
                  ),
                  _ReportCard(
                    icon: Icons.warning_amber,
                    label: 'Expiring Contracts',
                    color: AppColors.warning,
                  ),
                  _ReportCard(
                    icon: Icons.payment,
                    label: 'Payroll Export',
                    color: AppColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Payroll export section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payroll Export',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedYear,
                              decoration:
                                  const InputDecoration(labelText: 'Year'),
                              items: List.generate(5, (i) {
                                final y = DateTime.now().year - i;
                                return DropdownMenuItem(
                                    value: y, child: Text('$y'));
                              }),
                              onChanged: (v) =>
                                  setState(() => _selectedYear = v!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedMonth,
                              decoration:
                                  const InputDecoration(labelText: 'Month'),
                              items: List.generate(12, (i) {
                                final months = [
                                  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                                  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                                ];
                                return DropdownMenuItem(
                                    value: i + 1,
                                    child: Text(months[i]));
                              }),
                              onChanged: (v) =>
                                  setState(() => _selectedMonth = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      departments.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (_, __) => const SizedBox(),
                        data: (depts) => DropdownButtonFormField<String>(
                          value: _selectedDeptId,
                          decoration: const InputDecoration(
                              labelText: 'Department (optional)'),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text('All Departments')),
                            ...depts.map((d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text(d.name),
                                )),
                          ],
                          onChanged: (v) =>
                              setState(() => _selectedDeptId = v),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('Generate Payroll Report'),
                        onPressed: _exportPayroll,
                      ),
                    ],
                  ),
                ),
              ),

              // Results table
              if (_payrollData != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Results (${_payrollData!.length} employees)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Dept')),
                      DataColumn(label: Text('Days Worked')),
                      DataColumn(label: Text('Late (min)')),
                      DataColumn(label: Text('OT (hrs)')),
                      DataColumn(label: Text('Absences')),
                    ],
                    rows: _payrollData!
                        .map((r) => DataRow(cells: [
                              DataCell(Text(r['employee_code'] ?? '')),
                              DataCell(Text(
                                  '${r['last_name']}, ${r['first_name']}')),
                              DataCell(Text(r['department'] ?? '')),
                              DataCell(Text('${r['days_worked']}')),
                              DataCell(Text('${r['total_late_minutes']}')),
                              DataCell(Text('${r['overtime_hours']}')),
                              DataCell(Text('${r['absences']}')),
                            ]))
                        .toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ReportCard(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
