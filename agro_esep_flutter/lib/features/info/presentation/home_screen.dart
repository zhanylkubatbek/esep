import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../settings/presentation/cubit/locale_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/project_content.dart';
import '../../../widgets/hero_header.dart';
import '../../../core/l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = ProjectContent.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(L.of(context).homeTitleShort),
            backgroundColor: AppColors.heading,
            actions: [
              const _LanguageSwitcher(),
              const SizedBox(width: 12),
            ],
          ),
          SliverToBoxAdapter(
            child: HeroHeader(
              title: L.of(context).instituteName,
              subtitle: content.projectTitle,
              bullets: content.heroBullets,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList.list(
              children: [
                Text(
                  L.of(context).onlineCalculation,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.heading,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  content.calculatorIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.55,
                      ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () => context.go('/calculator'),
                  child: Text(L.of(context).ctaCalculate),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/about'),
                  child: Text(L.of(context).ctaAbout),
                ),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.call_outlined, color: AppColors.heroEnd),
                  title: Text(L.of(context).contactsLink),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: () => context.push('/contacts'),
                ),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  content.disclaimer,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Переключатель «КЫР | РУС» в аппбаре: активный язык выделен жирным.
class _LanguageSwitcher extends StatelessWidget {
  const _LanguageSwitcher();

  @override
  Widget build(BuildContext context) {
    final current = Localizations.localeOf(context).languageCode;

    Widget item(String code, String label) {
      final selected = current == code;
      return InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: selected
            ? null
            : () => context.read<LocaleCubit>().setLocale(Locale(code)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        item('ky', 'КЫР'),
        const Text('|', style: TextStyle(color: Colors.white38)),
        item('ru', 'РУС'),
      ],
    );
  }
}
