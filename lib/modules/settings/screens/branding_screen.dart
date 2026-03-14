import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/company_settings_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';

class BrandingScreen extends ConsumerStatefulWidget {
  const BrandingScreen({super.key});

  @override
  ConsumerState<BrandingScreen> createState() => _BrandingScreenState();
}

class _BrandingScreenState extends ConsumerState<BrandingScreen> {
  final _titleCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isUploading = false;
  bool _dirty = false;
  String? _selectedColor;

  static const _presetColors = <String>[
    '#2563EB', // Blue (default)
    '#4F46E5', // Indigo
    '#7C3AED', // Purple
    '#DB2777', // Pink
    '#DC2626', // Red
    '#EA580C', // Orange
    '#D97706', // Amber
    '#16A34A', // Green
    '#0D9488', // Teal
    '#0891B2', // Cyan
    '#475569', // Slate
    '#1E293B', // Dark navy
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _logoUrlCtrl.dispose();
    super.dispose();
  }

  void _syncFromSettings(CompanySettingsModel s) {
    if (_dirty) return;
    _titleCtrl.text = s.systemTitle ?? '';
    _logoUrlCtrl.text = s.logoUrl ?? '';
    _selectedColor = s.primaryColor ?? _presetColors.first;
  }

  Future<void> _pickAndUploadLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() => _isUploading = true);
    try {
      final url = await ref
          .read(settingsServiceProvider)
          .uploadLogo(bytes, file.name);
      setState(() {
        _logoUrlCtrl.text = url;
        _dirty = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final settings = ref.read(companySettingsProvider).valueOrNull;
      await ref.read(settingsServiceProvider).updateBranding(
            organizationId: settings?.organizationId,
            systemTitle: _titleCtrl.text.trim().isEmpty
                ? null
                : _titleCtrl.text.trim(),
            primaryColor: _selectedColor,
            logoUrl: _logoUrlCtrl.text.trim().isEmpty
                ? null
                : _logoUrlCtrl.text.trim(),
          );
      ref.invalidate(companySettingsProvider);
      setState(() => _dirty = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Branding settings saved.'),
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
    final role = ref.watch(currentUserRoleProvider).valueOrNull ?? '';

    if (role != 'admin' && role != 'hr_staff' && role != 'super_admin') {
      return const Scaffold(
        body: Center(
          child: Text('Access restricted to Admin and HR Staff.'),
        ),
      );
    }

    final settingsAsync = ref.watch(companySettingsProvider);

    return LoadingOverlay(
      isLoading: _isSaving,
      child: Scaffold(
        appBar: AppBar(title: const Text('Branding')),
        body: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (settings) {
            _syncFromSettings(settings);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Live preview
                  _PreviewCard(
                    primaryColor: parseHexColor(_selectedColor ??
                            settings.primaryColor ??
                            _presetColors.first) ??
                        AppColors.primary,
                    systemTitle: _titleCtrl.text.trim().isNotEmpty
                        ? _titleCtrl.text.trim()
                        : (settings.systemTitle ?? AppStrings.appName),
                    logoUrl: _logoUrlCtrl.text.trim().isNotEmpty
                        ? _logoUrlCtrl.text.trim()
                        : settings.logoUrl,
                  ),
                  const SizedBox(height: 32),

                  // System title
                  _Section(
                    title: 'System Title',
                    subtitle:
                        'Displayed in the sidebar and browser tab. '
                        'e.g., "Westbridge HRIS" or "St. Mary\'s College HRIS".',
                    child: TextField(
                      controller: _titleCtrl,
                      onChanged: (_) => setState(() => _dirty = true),
                      decoration: const InputDecoration(
                        hintText: 'e.g., Westbridge HRIS',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logo
                  _Section(
                    title: 'Logo',
                    subtitle: 'Upload from your computer or paste a public image URL.',
                    child: _LogoInput(
                      urlCtrl: _logoUrlCtrl,
                      isUploading: _isUploading,
                      onUrlChanged: () => setState(() => _dirty = true),
                      onBrowse: _pickAndUploadLogo,
                      onClear: () => setState(() {
                        _logoUrlCtrl.clear();
                        _dirty = true;
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Primary color
                  _Section(
                    title: 'Primary Color',
                    subtitle:
                        'Used for buttons, active nav items, and form highlights.',
                    child: _ColorPicker(
                      selected: _selectedColor ??
                          settings.primaryColor ??
                          _presetColors.first,
                      colors: _presetColors,
                      onSelected: (c) => setState(() {
                        _selectedColor = c;
                        _dirty = true;
                      }),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving || _isUploading ? null : _save,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Logo input ────────────────────────────────────────────────────────────────

class _LogoInput extends StatelessWidget {
  final TextEditingController urlCtrl;
  final bool isUploading;
  final VoidCallback onUrlChanged;
  final VoidCallback onBrowse;
  final VoidCallback onClear;

  const _LogoInput({
    required this.urlCtrl,
    required this.isUploading,
    required this.onUrlChanged,
    required this.onBrowse,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasLogo = urlCtrl.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo preview
        if (hasLogo) ...[
          Container(
            height: 80,
            width: 80,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                urlCtrl.text.trim(),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.broken_image_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 32,
                ),
              ),
            ),
          ),
        ],

        // URL field + browse button row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: urlCtrl,
                onChanged: (_) => onUrlChanged(),
                decoration: InputDecoration(
                  hintText: 'https://example.com/logo.png',
                  prefixIcon: const Icon(Icons.link_rounded),
                  suffixIcon: hasLogo
                      ? IconButton(
                          tooltip: 'Clear logo',
                          icon: const Icon(Icons.close_rounded, size: 18),
                          onPressed: onClear,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: isUploading ? null : onBrowse,
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.upload_rounded, size: 18),
                label: Text(isUploading ? 'Uploading…' : 'Browse'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Supported formats: PNG, JPG, SVG, WebP',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

// ── Preview card ──────────────────────────────────────────────────────────────

class _PreviewCard extends StatelessWidget {
  final Color primaryColor;
  final String systemTitle;
  final String? logoUrl;

  const _PreviewCard({
    required this.primaryColor,
    required this.systemTitle,
    required this.logoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          // Mini sidebar
          Container(
            width: 220,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: logoUrl != null && logoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            logoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.apartment_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        )
                      : const Icon(Icons.apartment_rounded,
                          color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        systemTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Text(
                        'HR Management',
                        style:
                            TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Color sample
          Row(
            children: [
              Container(
                height: 34,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Button',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                height: 34,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Text('Active item',
                    style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section wrapper ───────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Section(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ── Color picker ──────────────────────────────────────────────────────────────

class _ColorPicker extends StatelessWidget {
  final String selected;
  final List<String> colors;
  final ValueChanged<String> onSelected;

  const _ColorPicker(
      {required this.selected,
      required this.colors,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((hex) {
        final color = parseHexColor(hex) ?? AppColors.primary;
        final isSelected = selected.toUpperCase() == hex.toUpperCase();
        return GestureDetector(
          onTap: () => onSelected(hex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected ? AppColors.onSurface : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: isSelected
                ? const Icon(Icons.check_rounded,
                    color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}
