import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/organization_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class CreateAdminScreen extends ConsumerStatefulWidget {
  const CreateAdminScreen({super.key});

  @override
  ConsumerState<CreateAdminScreen> createState() => _CreateAdminScreenState();
}

class _CreateAdminScreenState extends ConsumerState<CreateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orgCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _autoConfirm = false;
  bool _obscurePassword = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _orgCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final result =
          await ref.read(organizationServiceProvider).createAdminAccount(
                orgName: _orgCtrl.text.trim(),
                email: _emailCtrl.text.trim(),
                autoConfirm: _autoConfirm,
                password: _autoConfirm ? _passwordCtrl.text : null,
              );

      ref.invalidate(organizationsProvider);

      if (mounted) {
        final message = result['message'] as String? ??
            (_autoConfirm
                ? 'Admin account for ${_emailCtrl.text.trim()} created.'
                : 'Invitation sent to ${_emailCtrl.text.trim()}.');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/super-admin');
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
    return LoadingOverlay(
      isLoading: _isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text('New Organization')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Organization name ─────────────────────────────────────
                Text(
                  'Organization',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'The company or school name.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _orgCtrl,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Organization Name',
                    hintText: 'e.g., Westbridge Inc. or St. Mary\'s College',
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Organization name is required.';
                    }
                    if (v.trim().length < 2) {
                      return 'Must be at least 2 characters.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // ── Admin email ───────────────────────────────────────────
                Text(
                  'Admin Account',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'The person who will manage this organization.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'admin@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email is required.';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Password (only when autoConfirm is on) ────────────────
                if (_autoConfirm) ...[
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    enabled: !_isSaving,
                    decoration: InputDecoration(
                      labelText: 'Admin Password',
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
                const SizedBox(height: 32),

                // ── Submit ────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSaving ? null : _submit,
                    icon: Icon(_autoConfirm
                        ? Icons.person_add_rounded
                        : Icons.send_rounded),
                    label: Text(
                        _autoConfirm ? 'Create Organization' : 'Send Invitation'),
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

// ── Auto Confirm toggle ────────────────────────────────────────────────────────

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
              'Auto Confirm Admin?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            dense: true,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  value
                      ? Icons.info_outline_rounded
                      : Icons.mail_outline_rounded,
                  size: 15,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value
                        ? 'No confirmation email will be sent. '
                            'The admin can log in immediately with the password you set.'
                        : 'An activation email will be sent to the admin. '
                            'They will set their own password via the link in the email.',
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
