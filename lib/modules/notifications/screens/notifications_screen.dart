import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/error_widget.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationListProvider);
    final authState = ref.watch(authStateProvider);
    final userId = authState.valueOrNull?.session?.user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: userId == null
                ? null
                : () async {
                    await ref
                        .read(notificationServiceProvider)
                        .markAllAsRead(userId);
                    ref.invalidate(notificationListProvider);
                  },
          ),
        ],
      ),
      body: notifAsync.when(
        loading: () => const HrisLoadingWidget(),
        error: (e, _) => HrisErrorWidget(message: e.toString()),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const HrisEmptyWidget(
              message: 'No notifications',
              icon: Icons.notifications_none_outlined,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            itemBuilder: (_, i) {
              final n = notifications[i];
              return Card(
                color: n.isRead ? null : Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _notifColor(n.type).withOpacity(0.15),
                    child: Icon(_notifIcon(n.type),
                        color: _notifColor(n.type), size: 20),
                  ),
                  title: Text(
                    n.title,
                    style: TextStyle(
                      fontWeight:
                          n.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (n.createdAt != null)
                        Text(
                          HrisDateUtils.timeAgo(n.createdAt!),
                          style: const TextStyle(fontSize: 11),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: !n.isRead && userId != null
                      ? () async {
                          await ref
                              .read(notificationServiceProvider)
                              .markAsRead(n.id);
                          ref.invalidate(notificationListProvider);
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _notifColor(String type) {
    switch (type) {
      case 'leave_approved':
        return Colors.green;
      case 'leave_rejected':
        return Colors.red;
      case 'late_alert':
        return Colors.orange;
      case 'contract_expiring':
        return Colors.deepOrange;
      case 'shift_reminder':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _notifIcon(String type) {
    switch (type) {
      case 'leave_approved':
        return Icons.check_circle;
      case 'leave_rejected':
        return Icons.cancel;
      case 'late_alert':
        return Icons.schedule;
      case 'contract_expiring':
        return Icons.warning_amber;
      case 'shift_reminder':
        return Icons.alarm;
      default:
        return Icons.notifications;
    }
  }
}
