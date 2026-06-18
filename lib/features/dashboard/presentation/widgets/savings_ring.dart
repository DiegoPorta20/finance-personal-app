import 'dart:math';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';

class SavingsRing extends StatefulWidget {
  final int currentAmount;
  final int goalAmount;

  const SavingsRing({
    super.key,
    required this.currentAmount,
    required this.goalAmount,
  });

  @override
  State<SavingsRing> createState() => _SavingsRingState();
}

class _SavingsRingState extends State<SavingsRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  double get _targetProgress => widget.goalAmount > 0
      ? (widget.currentAmount / widget.goalAmount).clamp(0.0, 1.0)
      : 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: _targetProgress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(SavingsRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentAmount != widget.currentAmount ||
        oldWidget.goalAmount != widget.goalAmount) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: _targetProgress,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? context.cCard,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ahorro del mes',
                  style: Theme.of(context).textTheme.titleMedium),
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) => Text(
                  '${(_animation.value * 100).toInt()}%',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 140,
            height: 140,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => CustomPaint(
                painter: _RingPainter(progress: _animation.value),
                child: child,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      CurrencyFormatter.formatDefault(widget.currentAmount),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppColors.accent),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'de ${CurrencyFormatter.formatDefault(widget.goalAmount)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;

  _RingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    final trackPaint = Paint()
      ..color = AppColors.divider
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
