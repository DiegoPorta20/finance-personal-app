import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/time_period.dart';

/// Barra reutilizable de selección de periodo (Diario/Semanal/Mensual/Anual).
/// Texto verde + subrayado en el periodo activo. Es "tonto": recibe el valor
/// seleccionado y notifica los cambios por [onChanged].
class PeriodSelector extends StatelessWidget {
  final TimePeriod selected;
  final ValueChanged<TimePeriod> onChanged;

  const PeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: TimePeriod.values.map((period) {
          final active = period == selected;
          return InkWell(
            onTap: () => onChanged(period),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    period.label,
                    style: TextStyle(
                      color:
                          active ? AppColors.accent : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 3,
                    width: 22,
                    decoration: BoxDecoration(
                      color: active ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
