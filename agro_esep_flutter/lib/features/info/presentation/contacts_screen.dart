import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/project_content.dart';
import '../../../core/l10n/app_localizations.dart';

/// Экран контактов — перенос футера сайта института:
/// на телефоне четыре колонки ужимаются в один список.
class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key, this.normativesVersion = '—'});

  /// Версия действующей нормативной базы — она же служит входом
  /// в режим администратора.
  final String normativesVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L.of(context).contactsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            ProjectContent.of(context).organization,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.heading,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 20),
          _ContactTile(
            icon: Icons.location_on_outlined,
            label: L.of(context).contactsAddress,
            value: ProjectContent.of(context).address,
          ),
          _ContactTile(
            icon: Icons.phone_outlined,
            label: L.of(context).contactsPhone,
            value: ProjectContent.phone,
          ),
          _ContactTile(
            icon: Icons.mail_outline,
            label: L.of(context).contactsEmail,
            value: ProjectContent.email,
          ),
          _ContactTile(
            icon: Icons.person_outline,
            label: L.of(context).contactsHead,
            value: ProjectContent.of(context).head,
          ),
          const SizedBox(height: 12),
          // Вход в режим администратора: длинное нажатие на версию базы.
          // Отдельной кнопки нет — экраном пользуются единицы человек
          // в институте, обычному пользователю он только мешал бы.
          GestureDetector(
            onLongPress: () => context.push('/admin/normatives'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                L.of(context).contactsNormativesBase(normativesVersion),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.heroEnd),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
