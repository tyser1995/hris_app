import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/employee_provider.dart';
import '../../../providers/department_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final String? employeeId;

  const EmployeeFormScreen({super.key, this.employeeId});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _codeCtrl = TextEditingController();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _middleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _employmentType = 'regular';
  String? _departmentId;
  String? _positionId;
  DateTime? _hireDate;

  bool _isGeneratingCode = false;

  bool get isEdit => widget.employeeId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      _loadEmployee();
    } else {
      _prefillCode();
    }
  }

  Future<void> _prefillCode() async {
    try {
      final code =
          await ref.read(settingsServiceProvider).previewNextCode();
      if (mounted && _codeCtrl.text.isEmpty) {
        _codeCtrl.text = code;
      }
    } catch (_) {
      // silently ignore — user can type manually
    }
  }

  Future<void> _generateCode() async {
    setState(() => _isGeneratingCode = true);
    try {
      final code =
          await ref.read(settingsServiceProvider).previewNextCode();
      if (mounted) _codeCtrl.text = code;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingCode = false);
    }
  }

  Future<void> _loadEmployee() async {
    final emp =
        await ref.read(employeeServiceProvider).getEmployee(widget.employeeId!);
    if (emp != null && mounted) {
      _codeCtrl.text = emp.employeeCode;
      _firstCtrl.text = emp.firstName;
      _lastCtrl.text = emp.lastName;
      _middleCtrl.text = emp.middleName ?? '';
      _emailCtrl.text = emp.email;
      _phoneCtrl.text = emp.phone ?? '';
      _addressCtrl.text = emp.address ?? '';
      setState(() {
        _employmentType = emp.employmentType;
        _departmentId = emp.departmentId;
        _positionId = emp.positionId;
        _hireDate = emp.hireDate;
      });
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _middleCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_hireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select hire date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final payload = {
      'employee_code': _codeCtrl.text.trim(),
      'first_name': _firstCtrl.text.trim(),
      'last_name': _lastCtrl.text.trim(),
      if (_middleCtrl.text.isNotEmpty) 'middle_name': _middleCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      if (_phoneCtrl.text.isNotEmpty) 'phone': _phoneCtrl.text.trim(),
      if (_addressCtrl.text.isNotEmpty) 'address': _addressCtrl.text.trim(),
      'employment_type': _employmentType,
      if (_departmentId != null) 'department_id': _departmentId,
      if (_positionId != null) 'position_id': _positionId,
      'hire_date': _hireDate!.toIso8601String().substring(0, 10),
    };

    try {
      if (isEdit) {
        await ref
            .read(employeeServiceProvider)
            .updateEmployee(widget.employeeId!, payload);
      } else {
        // Atomically increment sequence and get the authoritative code first,
        // then create the employee with it — prevents duplicates on retry.
        final code =
            await ref.read(settingsServiceProvider).incrementAndGetCode();
        await ref
            .read(employeeServiceProvider)
            .createEmployee({...payload, 'employee_code': code});
      }
      if (mounted) {
        context.go('/employees');
        ref.invalidate(employeeListProvider);
      }
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
    final positions =
        ref.watch(positionListProvider(_departmentId));

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit
              ? AppStrings.editEmployee
              : AppStrings.addEmployee),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _codeCtrl,
                        decoration: const InputDecoration(
                            labelText: AppStrings.employeeCode),
                        validator: (v) =>
                            Validators.required(v, field: 'Employee code'),
                      ),
                    ),
                    if (!isEdit) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Tooltip(
                          message: 'Generate from pattern',
                          child: IconButton.outlined(
                            onPressed: _isGeneratingCode ? null : _generateCode,
                            icon: _isGeneratingCode
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : const Icon(Icons.auto_fix_high_outlined,
                                    size: 20),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstCtrl,
                        decoration: const InputDecoration(
                            labelText: AppStrings.firstName),
                        validator: (v) =>
                            Validators.required(v, field: 'First name'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _lastCtrl,
                        decoration: const InputDecoration(
                            labelText: AppStrings.lastName),
                        validator: (v) =>
                            Validators.required(v, field: 'Last name'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _middleCtrl,
                  decoration: const InputDecoration(
                      labelText: AppStrings.middleName),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  decoration:
                      const InputDecoration(labelText: AppStrings.email),
                  validator: Validators.email,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Phone'),
                  validator: Validators.phone,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _employmentType,
                  decoration:
                      const InputDecoration(labelText: 'Employment Type'),
                  items: const [
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(
                        value: 'job_order', child: Text('Job Order')),
                    DropdownMenuItem(
                        value: 'contractual', child: Text('Contractual')),
                    DropdownMenuItem(
                        value: 'faculty', child: Text('Faculty')),
                    DropdownMenuItem(
                        value: 'janitorial', child: Text('Janitorial')),
                  ],
                  onChanged: (v) =>
                      setState(() => _employmentType = v!),
                ),
                const SizedBox(height: 12),
                departments.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (depts) => DropdownButtonFormField<String>(
                    value: _departmentId,
                    decoration: const InputDecoration(
                        labelText: AppStrings.department),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('No department')),
                      ...depts.map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          )),
                    ],
                    onChanged: (v) => setState(() {
                      _departmentId = v;
                      _positionId = null;
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                positions.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox(),
                  data: (pos) => DropdownButtonFormField<String>(
                    value: _positionId,
                    decoration: const InputDecoration(
                        labelText: AppStrings.position),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text('No position')),
                      ...pos.map((p) => DropdownMenuItem(
                            value: p.id,
                            child: Text(p.title),
                          )),
                    ],
                    onChanged: (v) => setState(() => _positionId = v),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(AppStrings.hireDate),
                  subtitle: Text(_hireDate != null
                      ? _hireDate!.toIso8601String().substring(0, 10)
                      : 'Not selected'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _hireDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _hireDate = picked);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _save,
                  child: Text(AppStrings.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
