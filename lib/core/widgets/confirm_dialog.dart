import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Diálogo de confirmación reutilizable. Devuelve `true` si el usuario confirma.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Eliminar',
  bool destructive = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: ctx.cCard,
      title: Text(title, style: TextStyle(color: ctx.cTextPrimary)),
      content: Text(message, style: TextStyle(color: ctx.cTextSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(
                color: destructive ? AppColors.error : AppColors.accent),
          ),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
