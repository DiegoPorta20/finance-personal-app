import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/notifications_provider.dart';
import '../../domain/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          TextButton(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).markAllAsRead(),
            child: const Text('Leer todas',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) =>
            const Center(child: Text('Error al cargar notificaciones')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.notifications_none,
                      color: AppColors.textSecondary, size: 64),
                  const SizedBox(height: 16),
                  Text('Sin notificaciones',
                      style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () =>
                ref.read(notificationsProvider.notifier).refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) => _NotificationTile(
                notification: notifications[index],
                onMarkRead: () => ref
                    .read(notificationsProvider.notifier)
                    .markAsRead(notifications[index].id),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onMarkRead;

  const _NotificationTile({
    required this.notification,
    required this.onMarkRead,
  });

  IconData get _icon => switch (notification.type) {
        'budget_alert' => Icons.warning_amber_rounded,
        'goal_progress' => Icons.flag,
        'payment_reminder' => Icons.calendar_today,
        _ => Icons.notifications,
      };

  Color get _iconColor => switch (notification.type) {
        'budget_alert' => AppColors.error,
        'goal_progress' => AppColors.accent,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, HH:mm');

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onMarkRead(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.check, color: AppColors.accent),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.read
                ? context.cCard
                : context.cCard.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
            border: notification.read
                ? null
                : Border.all(
                    color: _iconColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(notification.message,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(dateFormat.format(notification.createdAt),
                        style: TextStyle(
                            color: context.cTextSecondary, fontSize: 12)),
                  ],
                ),
              ),
              if (!notification.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _iconColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
