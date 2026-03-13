import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification_model.dart';
import 'auth_provider.dart';

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());

final notificationListProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.session?.user.id;
  if (userId == null) return [];
  return ref
      .watch(notificationServiceProvider)
      .getNotifications(userId: userId);
});

final unreadNotificationCountProvider = FutureProvider<int>((ref) async {
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.session?.user.id;
  if (userId == null) return 0;
  return ref.watch(notificationServiceProvider).getUnreadCount(userId);
});

final unreadNotificationsStreamProvider =
    StreamProvider<List<NotificationModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final userId = authState.valueOrNull?.session?.user.id;
  if (userId == null) return Stream.value([]);
  return ref.watch(notificationServiceProvider).streamUnread(userId);
});
