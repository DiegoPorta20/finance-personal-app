import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/recommendations_provider.dart';
import '../../domain/recommendation_model.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recomendaciones')),
      body: recsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text('Error al cargar',
                  style: Theme.of(context).textTheme.bodyLarge),
              TextButton(
                onPressed: () => ref.invalidate(recommendationsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (recs) {
          if (recs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.accent, size: 64),
                  const SizedBox(height: 16),
                  Text('Todo en orden',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('No tienes alertas por ahora',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }
          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: () async => ref.invalidate(recommendationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: recs.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _RecommendationCard(rec: recs[index]),
            ),
          );
        },
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;

  const _RecommendationCard({required this.rec});

  Color get _color => switch (rec.severity) {
        'high' => AppColors.error,
        'medium' => const Color(0xFFFF9500),
        _ => AppColors.accent,
      };

  IconData get _icon => switch (rec.type) {
        'budget_alert' => Icons.warning_amber_rounded,
        'savings_warning' => Icons.savings_outlined,
        'goal_at_risk' => Icons.flag_outlined,
        _ => Icons.lightbulb_outline,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rec.title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(rec.message,
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
