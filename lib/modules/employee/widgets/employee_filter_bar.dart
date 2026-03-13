import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../providers/department_provider.dart';

class EmployeeFilterBar extends ConsumerStatefulWidget {
  final ValueChanged<String?> onSearch;
  final ValueChanged<String?> onDepartmentFilter;
  final ValueChanged<String?> onTypeFilter;

  const EmployeeFilterBar({
    super.key,
    required this.onSearch,
    required this.onDepartmentFilter,
    required this.onTypeFilter,
  });

  @override
  ConsumerState<EmployeeFilterBar> createState() => _EmployeeFilterBarState();
}

class _EmployeeFilterBarState extends ConsumerState<EmployeeFilterBar> {
  final _searchCtrl = TextEditingController();
  String? _selectedType;

  static const _types = [
    ('regular', 'Regular'),
    ('job_order', 'Job Order'),
    ('contractual', 'Contractual'),
    ('faculty', 'Faculty'),
    ('janitorial', 'Janitorial'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departments = ref.watch(departmentListProvider);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: '${AppStrings.search} employees...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        widget.onSearch(null);
                      },
                    )
                  : null,
            ),
            onChanged: (v) => widget.onSearch(v.isEmpty ? null : v),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: departments.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (depts) => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: AppStrings.department,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All')),
                      ...depts.map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          )),
                    ],
                    onChanged: widget.onDepartmentFilter,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All')),
                    ..._types.map((t) =>
                        DropdownMenuItem(value: t.$1, child: Text(t.$2))),
                  ],
                  onChanged: (v) {
                    setState(() => _selectedType = v);
                    widget.onTypeFilter(v);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
