import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/organization_model.dart';
import '../../../providers/organization_provider.dart';
import '../../../providers/user_management_provider.dart';

/// Shows the "Create a new user" dialog. Returns true if a user was created.
/// Pass [preselectedOrgId] to lock the organization dropdown to a specific org.
Future<bool> showCreateUserDialog(
  BuildContext context, {
  String? preselectedOrgId,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _CreateUserDialog(preselectedOrgId: preselectedOrgId),
  );
  return result == true;
}

class _CreateUserDialog extends ConsumerStatefulWidget {
  final String? preselectedOrgId;

  const _CreateUserDialog({this.preselectedOrgId});

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _autoConfirm = true;
  bool _obscurePassword = true;
  bool _isSaving = false;

  String _selectedRole = 'employee';
  late String? _selectedOrgId;

  @override
  void initState() {
    super.initState();
    _selectedOrgId = widget.preselectedOrgId;
  }

  static const _roles = [
    ('admin',           'Admin'),
    ('hr_staff',        'HR Staff'),
    ('department_head', 'Department Head'),
    ('supervisor',      'Supervisor'),
    ('employee',        'Employee'),
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedOrgId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an organization.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(userManagementServiceProvider).createUser(
            email: _emailCtrl.text.trim(),
            password: _autoConfirm ? _passwordCtrl.text : null,
            autoConfirm: _autoConfirm,
            role: _selectedRole,
            organizationId: _selectedOrgId!,
          );

      ref.invalidate(orgUsersProvider);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _autoConfirm
                  ? 'User created successfully.'
                  : 'Invitation sent to ${_emailCtrl.text.trim()}.',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orgsAsync = ref.watch(organizationsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title bar ────────────────────────────────────────────
                Row(
                  children: [
                    const Icon(Icons.person_add_rounded, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Create a new user',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(false),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Email ────────────────────────────────────────────────
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required.';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password (only when autoConfirm is on) ───────────────
                if (_autoConfirm) ...[
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    enabled: !_isSaving,
                    decoration: InputDecoration(
                      labelText: 'User Password',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: _autoConfirm
                        ? (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required.';
                            }
                            if (v.length < 8) {
                              return 'Minimum 8 characters.';
                            }
                            return null;
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Auto Confirm toggle ───────────────────────────────────
                _AutoConfirmToggle(
                  value: _autoConfirm,
                  onChanged: _isSaving
                      ? null
                      : (v) {
                          setState(() {
                            _autoConfirm = v;
                            _passwordCtrl.clear();
                          });
                        },
                ),
                const SizedBox(height: 16),

                // ── Role ─────────────────────────────────────────────────
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    prefixIcon: Icon(Icons.shield_outlined),
                  ),
                  items: _roles.map((r) {
                    return DropdownMenuItem(
                      value: r.$1,
                      child: Text(r.$2),
                    );
                  }).toList(),
                  onChanged: _isSaving
                      ? null
                      : (v) => setState(() => _selectedRole = v!),
                ),
                const SizedBox(height: 16),

                // ── Organization ─────────────────────────────────────────
                orgsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text(
                    'Could not load organizations: $e',
                    style: const TextStyle(color: AppColors.error),
                  ),
                  data: (orgs) {
                    // If pre-selected, show a locked read-only field
                    if (widget.preselectedOrgId != null) {
                      final org = orgs
                          .where((o) => o.id == widget.preselectedOrgId)
                          .firstOrNull;
                      return TextFormField(
                        initialValue: org?.name ?? widget.preselectedOrgId,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Organization',
                          prefixIcon: Icon(Icons.business_outlined),
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedOrgId,
                      decoration: const InputDecoration(
                        labelText: 'Organization',
                        prefixIcon: Icon(Icons.business_outlined),
                      ),
                      hint: const Text('Select organization'),
                      items: orgs
                          .map((o) => DropdownMenuItem(
                                value: o.id,
                                child: Text(o.name),
                              ))
                          .toList(),
                      onChanged: _isSaving
                          ? null
                          : (v) => setState(() => _selectedOrgId = v),
                      validator: (v) =>
                          v == null ? 'Select an organization.' : null,
                    );
                  },
                ),
                const SizedBox(height: 28),

                // ── Submit ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create user',
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Auto Confirm toggle widget ────────────────────────────────────────────────

class _AutoConfirmToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _AutoConfirmToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: value,
            onChanged: onChanged,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
            title: const Text(
              'Auto Confirm User?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            dense: true,
          ),
          if (!value)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.mail_outline_rounded,
                      size: 15, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A confirmation email will be sent to the user. '
                      'They will need to click the link to activate their account.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A confirmation email will not be sent. '
                      'The user can log in immediately with the password you set.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
