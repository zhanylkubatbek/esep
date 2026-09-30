import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/chart_colors.dart';

/// Одна доля составной полосы.
class Share {
  const Share({
    required this.label,
    required this.value,
    required this.color,
    required this.valueLabel,
  });

  final String label;
  final double value;
  final Color color;

  /// Готовая подпись значения («26,9 га», «32 %») — форматирование
  /// остаётся снаружи, виджет ничего не считает.
  final String valueLabel;
}

/// Составная горизонтальная полоса «часть от целого» с легендой.
///
/// Горизонтальная, а не круговая: у категорий длинные названия
/// («Силосная кукуруза»), и на телефоне их негде разместить вокруг круга.
/// Между долями — двухпиксельный зазор цветом подложки, чтобы граница
/// читалась и без опоры на цвет.
class ShareBar extends StatelessWidget {
  const ShareBar({
    super.key,
    required this.shares,
    this.remainder,
    this.height = 34,
    this.showLegend = true,
  });

  final List<Share> shares;

  /// Незанятый остаток — рисуется нейтральным, в легенду не попадает.
  final ({String label, double value})? remainder;

  final double height;
  final bool showLegend;

  @override
  Widget build(BuildContext context) {
    final segments = <({Color color, double value, String? inlineLabel})>[
      for (final s in shares) (color: s.color, value: s.value, inlineLabel: null),
      if (remainder != null && remainder!.value > 0)
        (color: ChartColors.neutral, value: remainder!.value, inlineLabel: remainder!.label),
    ].where((s) => s.value > 0).toList();

    if (segments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: height,
            child: Row(
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Expanded(
                    flex: (segments[i].value * 1000).round().clamp(1, 1 << 30),
                    child: Container(
                      color: segments[i].color,
                      alignment: Alignment.center,
                      child: segments[i].inlineLabel == null
                          ? null
                          : Text(
                              segments[i].inlineLabel!,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (showLegend) ...[
          const SizedBox(height: 14),
          // Легенда обязательна: три цвета палитры на белом дают контраст
          // ниже 3:1, и подпись — то, что делает долю читаемой.
          for (final share in shares)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: share.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      share.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    share.valueLabel,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}
