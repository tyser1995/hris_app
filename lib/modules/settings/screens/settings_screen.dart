import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/employee_code_generator.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _patternCtrl = TextEditingController();
  bool _isSaving = false;
  bool _patternDirty = false;

  @override
  void initState() {
    super.initState();
    _patternCtrl.addListener(() => setState(() => _patternDirty = true));
  }

  @override
  void dispose() {
    _patternCtrl.dispose();
    super.dispose();
  }

  void _syncPattern(String value) {
    if (_patternCtrl.text != value) {
      _patternCtrl.text = value;
      _patternCtrl.selection =
          TextSelection.collapsed(offset: value.length);
    }
    setState(() => _patternDirty = false);
  }

  Future<void> _savePattern() async {
    final pattern = _patternCtrl.text.trim();
    if (pattern.isEmpty) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(settingsServiceProvider).updatePattern(pattern);
      ref.invalidate(companySettingsProvider);
      setState(() => _patternDirty = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee code pattern saved.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmResetSequence(int currentSeq) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Sequence?'),
        content: Text(
          'The current sequence counter is $currentSeq. '
          'Resetting it to 0 means the next generated code will start '
          'from 1 again. This may produce duplicate codes if you have '
          'existing employees.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(settingsServiceProvider).resetSequence();
      ref.invalidate(companySettingsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sequence reset to 0.'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Access guard ─────────────────────────────────────────────────────
    final isAdminOrHr = ref.watch(isAdminOrHrProvider);
    if (!isAdminOrHr) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    size: 40, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              const Text('Access Denied',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                'Only Admin and HR Staff can access Settings.',
                style: TextStyle(color: AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final settingsAsync = ref.watch(companySettingsProvider);

    return LoadingOverlay(
      isLoading: _isSaving,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: AppColors.surfaceLight,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.divider),
          ),
        ),
        body: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text(e.toString()),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref.invalidate(companySettingsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (settings) {
            // Sync controller once when data loads (not dirty)
            if (!_patternDirty) {
              WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _syncPattern(settings.employeeCodePattern));
            }

            final pattern = _patternCtrl.text.isNotEmpty
                ? _patternCtrl.text
                : settings.employeeCodePattern;

            final samples =
                EmployeeCodeGenerator.samples(pattern, settings.employeeCodeSequence);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(
                      icon: Icons.badge_outlined,
                      title: 'Employee Code Pattern',
                      subtitle:
                          'Define the format for auto-generating employee ID codes.',
                    ),
                    const SizedBox(height: 16),

                    // ── Pattern editor card ──────────────────────────────
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pattern field
                          TextFormField(
                            controller: _patternCtrl,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Pattern',
                              hintText: 'e.g.  YY-E###-MM',
                              helperText:
                                  'Use tokens below. Anything else is literal text.',
                              suffixIcon: _patternDirty
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.save_outlined,
                                          color: AppColors.primary),
                                      tooltip: 'Save pattern',
                                      onPressed: _savePattern,
                                    )
                                  : const Icon(Icons.check_circle_outline,
                                      color: AppColors.success),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Token chips
                          const Text(
                            'Available tokens',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: PatternToken.all.map((t) {
                              return _TokenChip(
                                token: t,
                                onTap: () => EmployeeCodeGenerator.insertToken(
                                    _patternCtrl, t.token),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),

                          // Preview
                          Row(
                            children: [
                              const Icon(Icons.preview_outlined,
                                  size: 16,
                                  color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              const Text(
                                'Preview — next 3 codes',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: samples
                                .map((code) => _CodePreviewChip(code: code))
                                .toList(),
                          ),

                          const SizedBox(height: 20),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _patternDirty ? _savePattern : null,
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text('Save Pattern'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Sequence card ─────────────────────────────────────
                    _SectionHeader(
                      icon: Icons.tag_rounded,
                      title: 'Sequence Counter',
                      subtitle:
                          'Tracks the last sequence number used in generated codes.',
                    ),
                    const SizedBox(height: 16),

                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: AppColors.primary
                                          .withOpacity(0.2)),
                                ),
                                child: Text(
                                  settings.employeeCodeSequence.toString(),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Last used sequence',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      settings.employeeCodeSequence == 0
                                          ? 'No codes generated yet.'
                                          : 'Next code will use sequence ${settings.employeeCodeSequence + 1}.',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  size: 16, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Resetting to 0 may create duplicate codes '
                                  'if employees with auto-generated codes already exist.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.onSurfaceVariant
                                        .withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          OutlinedButton.icon(
                            onPressed: settings.employeeCodeSequence == 0
                                ? null
                                : () => _confirmResetSequence(
                                    settings.employeeCodeSequence),
                            icon: const Icon(Icons.restart_alt_rounded,
                                size: 18),
                            label: const Text('Reset Sequence to 0'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side:
                                  const BorderSide(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Pattern reference ─────────────────────────────────
                    _SectionHeader(
                      icon: Icons.menu_book_outlined,
                      title: 'Pattern Reference',
                      subtitle: 'Token examples based on today\'s date.',
                    ),
                    const SizedBox(height: 16),

                    _Card(
                      child: Column(
                        children: [
                          _ReferenceRow(
                              token: 'YY',
                              description: '2-digit year',
                              example:
                                  (DateTime.now().year % 100)
                                      .toString()
                                      .padLeft(2, '0')),
                          _ReferenceRow(
                              token: 'YYYY',
                              description: '4-digit year',
                              example: DateTime.now().year.toString()),
                          _ReferenceRow(
                              token: 'MM',
                              description: '2-digit month',
                              example: DateTime.now()
                                  .month
                                  .toString()
                                  .padLeft(2, '0')),
                          _ReferenceRow(
                              token: 'DD',
                              description: '2-digit day',
                              example: DateTime.now()
                                  .day
                                  .toString()
                                  .padLeft(2, '0')),
                          _ReferenceRow(
                              token: '###',
                              description: '3-digit sequence (001, 002 …)',
                              example: '001'),
                          _ReferenceRow(
                              token: '####',
                              description: '4-digit sequence (0001, 0002 …)',
                              example: '0001',
                              isLast: true),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _TokenChip extends StatelessWidget {
  final PatternToken token;
  final VoidCallback onTap;

  const _TokenChip({required this.token, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '${token.description}  →  ${token.example}',
      child: ActionChip(
        onPressed: onTap,
        label: Text(
          token.token,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        backgroundColor: AppColors.primary.withOpacity(0.06),
        side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
        labelStyle: const TextStyle(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _CodePreviewChip extends StatelessWidget {
  final String code;

  const _CodePreviewChip({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary.withOpacity(0.25)),
      ),
      child: Text(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.secondary,
        ),
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  final String token;
  final String description;
  final String example;
  final bool isLast;

  const _ReferenceRow({
    required this.token,
    required this.description,
    required this.example,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(
                  token,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  example,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(color: AppColors.divider, height: 1),
      ],
    );
  }
}
