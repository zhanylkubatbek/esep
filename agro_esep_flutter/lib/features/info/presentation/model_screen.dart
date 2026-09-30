import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/l10n/app_localizations.dart';

/// Экран математической модели — формулы (1.1)-(1.8) и глоссарий
/// обозначений из документа института.
///
/// (1.1)-(1.6) — исходная постановка института, нумерация сохранена,
/// чтобы формулы на экране совпадали с документом. Расширения для
/// условий Кыргызстана дописаны в хвост: (1.7) ограничивает поголовье
/// породы, (1.8) вводит закупку кормов; она же добавляет слагаемое
/// в (1.1) и слагаемое z[j] в кормовой баланс (1.3).
class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(L.of(context).navModel),
          bottom: TabBar(
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: L.of(context).modelFormulas),
              Tab(text: L.of(context).modelGlossary),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_FormulasTab(), _GlossaryTab()],
        ),
      ),
    );
  }
}

class _FormulasTab extends StatelessWidget {
  const _FormulasTab();

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _FormulaBlock(
          number: '(1.1)',
          caption: l.modelFormulaObjective,
          latex: r'L(x,y,z) = \sum_{k \in K}\sum_{j \in J_0} c_{kj}x_{kj} '
              r'+ \sum_{h \in H}\sum_{l \in L} c_l^h y_l^h '
              r'+ \sum_{j \in J_0} p_j z_j \to \min',
        ),
        _FormulaBlock(
          number: '(1.2)',
          caption: l.modelFormulaLandLimit,
          latex: r'\sum_{j \in J_0} x_{kj} \leq s_k, \quad k \in K',
        ),
        _FormulaBlock(
          number: '(1.3)',
          caption: l.modelFormulaFeedBalance,
          latex: r'\sum_{k \in K} a_{kj}x_{kj} + z_j \geq '
              r'\sum_{h \in H}\sum_{l \in L} \alpha_{lj}^h y_l^h, \quad j \in J_0',
        ),
        _FormulaBlock(
          number: '(1.4)',
          caption: l.modelFormulaPlan,
          latex: r'\sum_{l \in L} \theta_l^h y_l^h \geq b^h, \quad h \in H',
        ),
        _FormulaBlock(
          number: '(1.5)',
          caption: l.modelFormulaNonNegative,
          latex: r'x_{kj} \geq 0, \quad k \in K,\ j \in J_0',
        ),
        _FormulaBlock(
          number: '(1.6)',
          caption: l.modelFormulaInteger,
          latex: r'y_l^h \in \mathbb{Z}_{\geq 0}, \quad l \in L,\ h \in H',
        ),
        _FormulaBlock(
          number: '(1.7)',
          caption: l.modelFormulaBreedLimit,
          latex: r'\sum_{h \in H} y_l^h \leq n_l, \quad l \in L',
        ),
        _FormulaBlock(
          number: '(1.8)',
          caption: l.modelFormulaPurchase,
          latex: r'z_j \geq 0, \quad j \in J_0',
        ),
      ],
    );
  }
}

class _FormulaBlock extends StatelessWidget {
  const _FormulaBlock({
    required this.number,
    required this.caption,
    required this.latex,
  });

  final String number;
  final String caption;
  final String latex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    number,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      caption,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.heading,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Math.tex(
                  latex,
                  textStyle: const TextStyle(fontSize: 17, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlossaryTab extends StatelessWidget {
  const _GlossaryTab();

  static List<({String symbol, String text})> _entries(L l) => [
        (symbol: r's_k', text: l.modelGlossaryArea),
        (symbol: r'a_{kj}', text: l.modelGlossaryYield),
        (symbol: r'c_{kj}', text: l.modelGlossaryCropCost),
        (symbol: r'\alpha_{lj}^h', text: l.modelGlossaryFeedNeed),
        (symbol: r'\theta_l^h', text: l.modelGlossaryYieldPerHead),
        (symbol: r'b^h', text: l.modelGlossaryPlan),
        (symbol: r'c_l^h', text: l.modelGlossaryHeadCost),
        (symbol: r'p_j', text: l.modelGlossaryFeedPrice),
        (symbol: r'n_l', text: l.modelGlossaryBreedLimit),
        (symbol: r'x_{kj}', text: l.modelGlossaryUnknownArea),
        (symbol: r'y_l^h', text: l.modelGlossaryUnknownHeads),
        (symbol: r'z_j', text: l.modelGlossaryUnknownPurchase),
      ];

  @override
  Widget build(BuildContext context) {
    final entries = _entries(L.of(context));
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Math.tex(
                entry.symbol,
                textStyle: const TextStyle(fontSize: 17, color: AppColors.heading),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
              ),
            ),
          ],
        );
      },
    );
  }
}
