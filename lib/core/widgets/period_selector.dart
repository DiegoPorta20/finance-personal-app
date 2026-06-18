import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/time_period.dart';

/// Barra reutilizable de selección de periodo (Diario/Semanal/Mensual/Anual).
/// Estilo "segmentado": el periodo activo es una pastilla verde. Es "tonto":
/// recibe el valor seleccionado y notifica los cambios por [onChanged].
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: TimePeriod.values.map((period) {
          final active = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    period.label,
                    style: TextStyle(
                      color: active ? Colors.black : AppColors.textSecondary,
                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
