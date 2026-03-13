import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/schedule_service.dart';
import '../../../shared/widgets/loading_overlay.dart';

class ScheduleEditorScreen extends ConsumerStatefulWidget {
  const ScheduleEditorScreen({super.key});

  @override
  ConsumerState<ScheduleEditorScreen> createState() =>
      _ScheduleEditorScreenState();
}

class _ScheduleEditorScreenState
    extends ConsumerState<ScheduleEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _type = 'regular';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _periods = [
    {'start_time': '08:00', 'end_time': '17:00', 'period_label': 'Full Day'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _addPeriod() {
    setState(() => _periods.add({
          'start_time': '08:00',
          'end_time': '17:00',
          'period_label': 'Period ${_periods.length + 1}',
        }));
  }

  void _removePeriod(int index) {
    if (_periods.length > 1) setState(() => _periods.removeAt(index));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await ScheduleService().createSchedule(
        name: _nameCtrl.text.trim(),
        type: _type,
        details: _periods,
      );

      if (mounted) {
        context.go('/scheduling');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule created!')),
        );
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
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(title: const Text('New Schedule')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Schedule Name'),
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration:
                      const InputDecoration(labelText: 'Schedule Type'),
                  items: const [
                    DropdownMenuItem(value: 'regular', child: Text('Regular')),
                    DropdownMenuItem(value: 'broken', child: Text('Broken/Split')),
                    DropdownMenuItem(
                        value: 'flexible', child: Text('Flexible')),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Time Periods',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_type == 'broken')
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Period'),
                        onPressed: _addPeriod,
                      ),
                  ],
                ),
                ..._periods.asMap().entries.map((e) => _PeriodEditor(
                      index: e.key,
                      data: e.value,
                      onRemove: () => _removePeriod(e.key),
                      canRemove: _periods.length > 1,
                      onChanged: (updated) => setState(
                          () => _periods[e.key] = updated),
                    )),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Save Schedule')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PeriodEditor extends StatefulWidget {
  final int index;
  final Map<String, dynamic> data;
  final VoidCallback onRemove;
  final bool canRemove;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const _PeriodEditor({
    required this.index,
    required this.data,
    required this.onRemove,
    required this.canRemove,
    required this.onChanged,
  });

  @override
  State<_PeriodEditor> createState() => _PeriodEditorState();
}

class _PeriodEditorState extends State<_PeriodEditor> {
  late TextEditingController _labelCtrl;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(
        text: widget.data['period_label'] as String? ?? '');
    _startCtrl = TextEditingController(
        text: widget.data['start_time'] as String? ?? '');
    _endCtrl = TextEditingController(
        text: widget.data['end_time'] as String? ?? '');
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  void _notify() => widget.onChanged({
        'period_label': _labelCtrl.text,
        'start_time': _startCtrl.text,
        'end_time': _endCtrl.text,
      });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Period ${widget.index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (widget.canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.error),
                    onPressed: widget.onRemove,
                  ),
              ],
            ),
            TextFormField(
              controller: _labelCtrl,
              decoration:
                  const InputDecoration(labelText: 'Label (e.g. Morning)'),
              onChanged: (_) => _notify(),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _startCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Start Time (HH:mm)'),
                    onChanged: (_) => _notify(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _endCtrl,
                    decoration:
                        const InputDecoration(labelText: 'End Time (HH:mm)'),
                    onChanged: (_) => _notify(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
