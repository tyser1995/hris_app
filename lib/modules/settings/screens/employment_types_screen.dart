import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/employment_type_provider.dart';
import '../../../providers/settings_provider.dart';

class EmploymentTypesScreen extends ConsumerWidget {
  const EmploymentTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdminOrHr = ref.watch(isAdminOrHrProvider);
    if (!isAdminOrHr) {
      return Scaffold(
        appBar: AppBar(title: const Text('Employment Types')),
        body: const Center(child: Text('Access restricted to Admin and HR Staff.')),
      );
    }

    final typesAsync = ref.watch(employmentTypesProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Employment Types'),
        backgroundColor: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.divider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTypeDialog(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Type'),
      ),
      body: typesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('$e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(employmentTypesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (types) => types.isEmpty
            ? _EmptyState(onAdd: () => _showTypeDialog(context, ref))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                itemCount: types.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _TypeTile(
                  name: types[i].name,
                  onEdit: () => _showTypeDialog(context, ref,
                      id: types[i].id, current: types[i].name),
                  onDelete: () =>
                      _confirmDelete(context, ref, types[i].id, types[i].name),
                ),
              ),
      ),
    );
  }

  Future<void> _showTypeDialog(
    BuildContext context,
    WidgetRef ref, {
    String? id,
    String? current,
  }) async {
    final ctrl = TextEditingController(text: current);
    final isEdit = id != null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Employment Type' : 'Add Employment Type'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Type name',
            hintText: 'e.g. Regular, Faculty, Contractual',
          ),
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isEdit ? 'Save' : 'Add'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = ctrl.text.trim();
    if (name.isEmpty) return;

    try {
      final service = ref.read(employmentTypeServiceProvider);
      if (isEdit) {
        await service.updateEmploymentType(id: id, name: name);
      } else {
        final settings = ref.read(companySettingsProvider).valueOrNull;
        final orgId = settings?.organizationId;
        if (orgId == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Organization not found. Please try again.'),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return;
        }
        await service.createEmploymentType(name: name, organizationId: orgId);
      }
      ref.invalidate(employmentTypesProvider);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Employment Type?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "$name"?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Employees currently assigned this type will retain '
                      'the value but it will no longer appear in the dropdown.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(employmentTypeServiceProvider).deleteEmploymentType(id);
      ref.invalidate(employmentTypesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$name" deleted.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}

// ── Type tile ──────────────────────────────────────────────────────────────────

class _TypeTile extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TypeTile({
    required this.name,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.work_outline_rounded,
              size: 20, color: AppColors.primary),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.work_outline_rounded,
                size: 40, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          const Text(
            'No employment types yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add types like Regular, Faculty, or Contractual.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add Employment Type'),
          ),
        ],
      ),
    );
  }
}
