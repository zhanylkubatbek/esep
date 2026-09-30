import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/farm_model.dart';
import '../../../../data/normatives/normatives.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';
import '../widgets/wizard_scaffold.dart';
import '../../../../core/l10n/app_localizations.dart';

class StepBreedsScreen extends StatelessWidget {
  const StepBreedsScreen({super.key, required this.cubit});

  final CalculatorCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      bloc: cubit,
      builder: (context, state) {
        final names = cubit.normatives.namesFor(L.of(context).localeName);
        final breeds = cubit.normatives.breedsById;
        final canProceed = state.hasBreeds && cubit.selectedBreedsCoverPlan;
        final uncovered = cubit.uncoveredProductIds.map(names.product).toList();

        return WizardScaffold(
          step: 4,
          totalSteps: 5,
          question: L.of(context).stepBreedsQuestion,
          hint: L.of(context).stepBreedsHint,
          actionLabel: L.of(context).ctaNext,
          onAction: canProceed ? () => context.go('/calculator/review') : null,
          footnote: state.hasBreeds && uncovered.isNotEmpty
              ? L.of(context).stepBreedsUncovered(uncovered.join(', '))
              : null,
          child: Column(
            children: [
              for (final entry in breeds.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _BreedTile(
                    breedName: names.breed(entry.key),
                    products: entry.value,
                    names: names,
                    selected: state.selectedBreedIds.contains(entry.key),
                    limit: state.breedLimits[entry.key],
                    onTap: () => cubit.toggleBreed(entry.key),
                    onLimitChanged: (heads) =>
                        cubit.setBreedLimit(entry.key, heads),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _BreedTile extends StatelessWidget {
  const _BreedTile({
    required this.breedName,
    required this.products,
    required this.names,
    required this.selected,
    required this.limit,
    required this.onTap,
    required this.onLimitChanged,
  });

  final String breedName;
  final List<BreedProduct> products;
  final NormativeNames names;
  final bool selected;

  /// Предел поголовья n[l], null — порода не ограничена.
  final double? limit;
  final VoidCallback onTap;
  final ValueChanged<double?> onLimitChanged;

  @override
  Widget build(BuildContext context) {
    // Нормативы подписаны прямо на карточке: хозяйство видит, по какому
    // числу его посчитают, и может возразить заранее.
    final normativeLine = products
        .map((p) => '${names.product(p.productId).toLowerCase()} '
            '${_format(p.yieldPerHead)} ${L.of(context).unitTonsPerYear}')
        .join(' · ');

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.heading : AppColors.divider,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected ? Icons.check_box : Icons.check_box_outline_blank,
                color: selected ? AppColors.heading : AppColors.textSecondary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      breedName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      normativeLine,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                    // Предел появляется только у выбранной породы:
                    // спрашивать «сколько голов» про породу, которую
                    // хозяйство не держит, бессмысленно.
                    if (selected) ...[
                      const SizedBox(height: 12),
                      // Карточка целиком — кнопка выбора породы, поэтому
                      // блок с пределом перехватывает нажатия на себя:
                      // иначе тап мимо поля ввода снимал бы галочку
                      // вместе с только что введённым числом.
                      GestureDetector(
                        onTap: () {},
                        behavior: HitTestBehavior.opaque,
                        child: _LimitField(
                          // Ключ по породе: без него Flutter переиспользует
                          // состояние поля соседней карточки при снятии
                          // галочки, и чужое число остаётся на экране.
                          key: ValueKey('limit-$breedName'),
                          initialValue: limit,
                          onChanged: onLimitChanged,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _format(double value) =>
      value == value.roundToDouble() ? value.round().toString() : value.toString();
}

/// Необязательный предел поголовья породы — n[l] из (1.7).
///
/// Пустое поле означает «не ограничиваю», а не ноль голов: без
/// границы модель ставит всё стадо на одну самую дешёвую породу,
/// потому что оптимум линейной задачи всегда угловой. Хозяйство,
/// у которого конечное число скотомест и рабочих рук, задаёт
/// границу и получает осмысленный смешанный состав.
class _LimitField extends StatefulWidget {
  const _LimitField({super.key, required this.initialValue, required this.onChanged});

  final double? initialValue;
  final ValueChanged<double?> onChanged;

  @override
  State<_LimitField> createState() => _LimitFieldState();
}

class _LimitFieldState extends State<_LimitField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue == null
        ? ''
        : widget.initialValue!.round().toString(),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l.stepBreedsLimitLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 76,
              child: TextField(
                controller: _controller,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '—',
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.divider),
                  ),
                ),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.heading,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                onChanged: (raw) => widget.onChanged(double.tryParse(raw)),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.unitHeads,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l.stepBreedsLimitHint,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
        ),
      ],
    );
  }
}
