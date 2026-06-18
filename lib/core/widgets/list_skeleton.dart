import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Placeholder de carga: tarjetas grises (mejor que un spinner, muestra
/// la estructura mientras llegan los datos).
class ListSkeleton extends StatelessWidget {
  final int count;
  final double height;

  const ListSkeleton({super.key, this.count = 6, this.height = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => Container(
        height: height,
        decoration: BoxDecoration(
          color: context.cCard,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
