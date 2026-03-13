import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import 'responsive_layout.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  // ── Nav item definitions ────────────────────────────────────────────────

  // Shown in mobile bottom bar (5 items)
  static const List<_NavItem> _mobileItems = [
    _NavItem(icon: Icons.dashboard_outlined,        selectedIcon: Icons.dashboard_rounded,             label: AppStrings.dashboard,   route: '/dashboard'),
    _NavItem(icon: Icons.people_outline_rounded,    selectedIcon: Icons.people_rounded,                label: AppStrings.employees,   route: '/employees'),
    _NavItem(icon: Icons.access_time_outlined,      selectedIcon: Icons.access_time_filled_rounded,    label: AppStrings.attendance,  route: '/attendance'),
    _NavItem(icon: Icons.event_note_outlined,       selectedIcon: Icons.event_note_rounded,            label: AppStrings.leave,       route: '/leave'),
    _NavItem(icon: Icons.notifications_outlined,    selectedIcon: Icons.notifications_rounded,         label: AppStrings.notifications, route: '/notifications'),
  ];

  // Shown in sidebar (all main navigation — Settings handled separately)
  static const List<_NavItem> _sidebarItems = [
    _NavItem(icon: Icons.dashboard_outlined,        selectedIcon: Icons.dashboard_rounded,             label: AppStrings.dashboard,   route: '/dashboard'),
    _NavItem(icon: Icons.people_outline_rounded,    selectedIcon: Icons.people_rounded,                label: AppStrings.employees,   route: '/employees'),
    _NavItem(icon: Icons.access_time_outlined,      selectedIcon: Icons.access_time_filled_rounded,    label: AppStrings.attendance,  route: '/attendance'),
    _NavItem(icon: Icons.event_note_outlined,       selectedIcon: Icons.event_note_rounded,            label: AppStrings.leave,       route: '/leave'),
    _NavItem(icon: Icons.calendar_month_outlined,   selectedIcon: Icons.calendar_month_rounded,        label: AppStrings.scheduling,  route: '/scheduling'),
    _NavItem(icon: Icons.bar_chart_outlined,        selectedIcon: Icons.bar_chart_rounded,             label: AppStrings.reports,     route: '/reports'),
    _NavItem(icon: Icons.notifications_outlined,    selectedIcon: Icons.notifications_rounded,         label: AppStrings.notifications, route: '/notifications'),
  ];

  // Sub-items shown under the expandable Settings group (admin/hr only)
  static const List<_NavItem> _settingsSubItems = [
    _NavItem(icon: Icons.badge_outlined,            selectedIcon: Icons.badge_rounded,                 label: 'ID Management',        route: '/settings'),
    _NavItem(icon: Icons.manage_accounts_outlined,  selectedIcon: Icons.manage_accounts_rounded,       label: 'Access Management',    route: '/settings/access'),
  ];

  // Overflow items shown in the mobile "More" sheet
  static const List<_NavItem> _moreItems = [
    _NavItem(icon: Icons.calendar_month_outlined,   selectedIcon: Icons.calendar_month_rounded,        label: AppStrings.scheduling,  route: '/scheduling'),
    _NavItem(icon: Icons.bar_chart_outlined,        selectedIcon: Icons.bar_chart_rounded,             label: AppStrings.reports,     route: '/reports'),
  ];

  // ── Helpers ────────────────────────────────────────────────────────────

  static bool _isAdminOrHr(String role) =>
      role == 'admin' || role == 'hr_staff';

  static int _indexFromLocation(String location, List<_NavItem> items) {
    for (int i = 0; i < items.length; i++) {
      if (location.startsWith(items[i].route)) return i;
    }
    return -1; // no match — nothing highlighted
  }

  static Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(authServiceProvider).signOut();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).valueOrNull ?? 0;
    final role = ref.watch(currentUserRoleProvider).valueOrNull ?? '';
    final location = GoRouterState.of(context).matchedLocation;
    final isAdminHr = _isAdminOrHr(role);

    final sidebarSelected = _indexFromLocation(location, _sidebarItems);
    final mobileSelected  = _indexFromLocation(location, _mobileItems);

    void logout() => _confirmLogout(context, ref);
    void navigate(String route) => context.go(route);

    return ResponsiveLayout(
      mobile: _MobileShell(
        child: child,
        selectedIndex: mobileSelected,
        mobileItems: _mobileItems,
        moreItems: _moreItems,
        settingsSubItems: isAdminHr ? _settingsSubItems : const [],
        unreadCount: unreadCount,
        role: role,
        onTap: navigate,
        onLogout: logout,
      ),
      tablet: _SidebarShell(
        child: child,
        selectedIndex: sidebarSelected,
        navItems: _sidebarItems,
        settingsSubItems: isAdminHr ? _settingsSubItems : const [],
        location: location,
        unreadCount: unreadCount,
        role: role,
        onTap: navigate,
        onLogout: logout,
        extended: false,
      ),
      desktop: _SidebarShell(
        child: child,
        selectedIndex: sidebarSelected,
        navItems: _sidebarItems,
        settingsSubItems: isAdminHr ? _settingsSubItems : const [],
        location: location,
        unreadCount: unreadCount,
        role: role,
        onTap: navigate,
        onLogout: logout,
        extended: true,
      ),
    );
  }
}

// ─── Mobile: Bottom Navigation + More Sheet ──────────────────────────────────

class _MobileShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final List<_NavItem> mobileItems;
  final List<_NavItem> moreItems;
  final List<_NavItem> settingsSubItems;
  final int unreadCount;
  final String role;
  final ValueChanged<String> onTap;
  final VoidCallback onLogout;

  const _MobileShell({
    required this.child,
    required this.selectedIndex,
    required this.mobileItems,
    required this.moreItems,
    required this.settingsSubItems,
    required this.unreadCount,
    required this.role,
    required this.onTap,
    required this.onLogout,
  });

  void _showMore(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MobileMoreSheet(
        moreItems: moreItems,
        settingsSubItems: settingsSubItems,
        onNavigate: (route) {
          Navigator.pop(context);
          onTap(route);
        },
        onLogout: () {
          Navigator.pop(context);
          onLogout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navIndex =
        selectedIndex >= 0 && selectedIndex < mobileItems.length
            ? selectedIndex
            : mobileItems.length; // point to "More"

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceLight,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: NavigationBar(
          selectedIndex: navIndex,
          onDestinationSelected: (index) {
            if (index == mobileItems.length) {
              _showMore(context);
            } else {
              onTap(mobileItems[index].route);
            }
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          destinations: [
            ...mobileItems.map((item) {
              final isNotif = item.route == '/notifications';
              return NavigationDestination(
                icon: Badge(
                  isLabelVisible: isNotif && unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: Icon(item.icon),
                ),
                selectedIcon: Badge(
                  isLabelVisible: isNotif && unreadCount > 0,
                  label: Text('$unreadCount'),
                  child: Icon(item.selectedIcon),
                ),
                label: item.label,
              );
            }),
            const NavigationDestination(
              icon: Icon(Icons.more_horiz_rounded),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileMoreSheet extends StatelessWidget {
  final List<_NavItem> moreItems;
  final List<_NavItem> settingsSubItems;
  final ValueChanged<String> onNavigate;
  final VoidCallback onLogout;

  const _MobileMoreSheet({
    required this.moreItems,
    required this.settingsSubItems,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            ...moreItems.map((item) => ListTile(
                  leading: Icon(item.icon,
                      color: AppColors.onSurfaceVariant, size: 22),
                  title: Text(item.label),
                  onTap: () => onNavigate(item.route),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 24),
                )),

            if (settingsSubItems.isNotEmpty) ...[
              const Divider(color: AppColors.divider, height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                child: Row(
                  children: const [
                    Icon(Icons.settings_outlined,
                        size: 12, color: AppColors.onSurfaceVariant),
                    SizedBox(width: 6),
                    Text(
                      'Settings',
                      style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              ...settingsSubItems.map((item) => ListTile(
                    leading: Icon(item.icon,
                        color: AppColors.onSurfaceVariant, size: 22),
                    title: Text(item.label),
                    onTap: () => onNavigate(item.route),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 24),
                  )),
            ],

            const Divider(color: AppColors.divider, height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 22),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w600),
              ),
              onTap: onLogout,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 24),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tablet/Desktop: Sidebar Navigation ──────────────────────────────────────

class _SidebarShell extends StatelessWidget {
  final Widget child;
  final int selectedIndex;
  final List<_NavItem> navItems;
  final List<_NavItem> settingsSubItems;
  final String location;
  final int unreadCount;
  final String role;
  final ValueChanged<String> onTap;
  final VoidCallback onLogout;
  final bool extended;

  const _SidebarShell({
    required this.child,
    required this.selectedIndex,
    required this.navItems,
    required this.settingsSubItems,
    required this.location,
    required this.unreadCount,
    required this.role,
    required this.onTap,
    required this.onLogout,
    required this.extended,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            selectedIndex: selectedIndex,
            navItems: navItems,
            settingsSubItems: settingsSubItems,
            location: location,
            unreadCount: unreadCount,
            role: role,
            onTap: onTap,
            onLogout: onLogout,
            extended: extended,
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatefulWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final List<_NavItem> settingsSubItems;
  final String location;
  final int unreadCount;
  final String role;
  final ValueChanged<String> onTap;
  final VoidCallback onLogout;
  final bool extended;

  const _Sidebar({
    required this.selectedIndex,
    required this.navItems,
    required this.settingsSubItems,
    required this.location,
    required this.unreadCount,
    required this.role,
    required this.onTap,
    required this.onLogout,
    required this.extended,
  });

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  late bool _settingsExpanded;

  @override
  void initState() {
    super.initState();
    _settingsExpanded = widget.location.startsWith('/settings');
  }

  @override
  void didUpdateWidget(_Sidebar old) {
    super.didUpdateWidget(old);
    // Auto-expand when navigating into any settings sub-route
    if (widget.location.startsWith('/settings') && !_settingsExpanded) {
      setState(() => _settingsExpanded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.extended ? 240.0 : 72.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.sidebarGradient,
          border: Border(
            right: BorderSide(color: Color(0xFF334155), width: 1),
          ),
        ),
        child: Column(
          children: [
            _SidebarHeader(extended: widget.extended),
            const Divider(color: Color(0xFF334155), height: 1),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    vertical: 12, horizontal: 8),
                children: [
                  // Regular nav items
                  ...List.generate(widget.navItems.length, (index) {
                    final item = widget.navItems[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _SidebarItem(
                        item: item,
                        isSelected: index == widget.selectedIndex,
                        extended: widget.extended,
                        badge: item.route == '/notifications' &&
                                widget.unreadCount > 0
                            ? widget.unreadCount
                            : null,
                        onTap: () => widget.onTap(item.route),
                      ),
                    );
                  }),

                  // Settings expandable group (admin/hr only)
                  if (widget.settingsSubItems.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    _SidebarSettingsGroup(
                      subItems: widget.settingsSubItems,
                      location: widget.location,
                      extended: widget.extended,
                      expanded: _settingsExpanded,
                      onToggle: () => setState(
                          () => _settingsExpanded = !_settingsExpanded),
                      onTap: widget.onTap,
                    ),
                  ],
                ],
              ),
            ),

            // Role badge
            if (widget.role.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.extended
                      ? Container(
                          key: const ValueKey('ext'),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.shield_outlined,
                                  color: AppColors.sidebarText, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                widget.role
                                    .replaceAll('_', ' ')
                                    .split(' ')
                                    .map((w) => w.isEmpty
                                        ? w
                                        : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
                                    .join(' '),
                                style: const TextStyle(
                                  color: AppColors.sidebarText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Icon(Icons.shield_outlined,
                          key: ValueKey('col'),
                          color: AppColors.sidebarText,
                          size: 18),
                ),
              ),

            // Logout button
            _SidebarLogoutButton(
                extended: widget.extended, onTap: widget.onLogout),
          ],
        ),
      ),
    );
  }
}

// ─── Expandable Settings group ────────────────────────────────────────────────

class _SidebarSettingsGroup extends StatelessWidget {
  final List<_NavItem> subItems;
  final String location;
  final bool extended;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onTap;

  const _SidebarSettingsGroup({
    required this.subItems,
    required this.location,
    required this.extended,
    required this.expanded,
    required this.onToggle,
    required this.onTap,
  });

  bool get _isActive => location.startsWith('/settings');

  @override
  Widget build(BuildContext context) {
    // Collapsed sidebar: show icon only, tap navigates to first sub-item
    if (!extended) {
      return Tooltip(
        message: 'Settings',
        preferBelow: false,
        child: InkWell(
          onTap: () => onTap(subItems.first.route),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: _isActive
                  ? AppColors.sidebarSelected
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                _isActive
                    ? Icons.settings_rounded
                    : Icons.settings_outlined,
                color: _isActive
                    ? AppColors.sidebarTextSelected
                    : AppColors.sidebarText,
                size: 20,
              ),
            ),
          ),
        ),
      );
    }

    // Extended sidebar: expandable group
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            clipBehavior: Clip.hardEdge,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _isActive && !expanded
                  ? AppColors.sidebarSelected
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  _isActive
                      ? Icons.settings_rounded
                      : Icons.settings_outlined,
                  color: _isActive
                      ? AppColors.sidebarTextSelected
                      : AppColors.sidebarText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      color: _isActive
                          ? AppColors.sidebarTextSelected
                          : AppColors.sidebarText,
                      fontSize: 13,
                      fontWeight:
                          _isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: _isActive
                        ? AppColors.sidebarTextSelected
                        : AppColors.sidebarText,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Sub-items with animated expand
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: expanded
              ? Column(
                  children: subItems.map((item) {
                    final isSubSelected = location == item.route ||
                        (item.route != '/settings' &&
                            location.startsWith(item.route));
                    return Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: _SidebarSubItem(
                        item: item,
                        isSelected: isSubSelected,
                        onTap: () => onTap(item.route),
                      ),
                    );
                  }).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _SidebarSubItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarSubItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        clipBehavior: Clip.hardEdge,
        padding: const EdgeInsets.only(left: 20, right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.sidebarSelected.withOpacity(0.85)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Indent indicator line
            Container(
              width: 2,
              height: 16,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.6)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              size: 16,
              color: isSelected
                  ? AppColors.sidebarTextSelected
                  : AppColors.sidebarText.withOpacity(0.7),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.sidebarTextSelected
                      : AppColors.sidebarText.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sidebar sub-widgets ──────────────────────────────────────────────────────

class _SidebarHeader extends StatelessWidget {
  final bool extended;

  const _SidebarHeader({required this.extended});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: extended
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.apartment_rounded,
                color: Colors.white, size: 20),
          ),
          if (extended) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.appName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Text(
                    'HR Management',
                    style: TextStyle(
                      color: AppColors.sidebarText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final bool extended;
  final int? badge;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.extended,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: extended ? '' : item.label,
      preferBelow: false,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 44,
          clipBehavior: Clip.hardEdge,
          padding: EdgeInsets.symmetric(horizontal: extended ? 12 : 0),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.sidebarSelected
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: extended
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badge != null,
                label: Text('$badge'),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected
                      ? AppColors.sidebarTextSelected
                      : AppColors.sidebarText,
                  size: 20,
                ),
              ),
              if (extended) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.sidebarTextSelected
                          : AppColors.sidebarText,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
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

class _SidebarLogoutButton extends StatelessWidget {
  final bool extended;
  final VoidCallback onTap;

  const _SidebarLogoutButton(
      {required this.extended, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Tooltip(
        message: extended ? '' : 'Sign Out',
        preferBelow: false,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 44,
            clipBehavior: Clip.hardEdge,
            padding:
                EdgeInsets.symmetric(horizontal: extended ? 12 : 0),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: extended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  color: AppColors.error.withOpacity(0.75),
                  size: 20,
                ),
                if (extended) ...[
                  const SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.error.withOpacity(0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Data ─────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}
