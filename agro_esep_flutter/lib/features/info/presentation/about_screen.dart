import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/project_content.dart';
import '../../../widgets/section_card.dart';
import '../../../core/l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(L.of(context).aboutTab),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: L.of(context).aboutTab),
              Tab(text: L.of(context).goalsTab),
              Tab(text: L.of(context).resultsTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AboutTab(),
            _GoalsTab(),
            _ResultsTab(),
          ],
        ),
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Paragraph(
          title: L.of(context).aboutTab,
          text: ProjectContent.of(context).aboutProject,
        ),
        const SizedBox(height: 24),
        _Paragraph(
          title: L.of(context).relevanceTitle,
          text: ProjectContent.of(context).relevance,
        ),
      ],
    );
  }
}

class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _Paragraph(
          title: L.of(context).goalTitle,
          text: ProjectContent.of(context).projectGoal,
        ),
        const SizedBox(height: 20),
        SectionCard(
          badge: L.of(context).tasksBadge,
          badgeColor: AppColors.accent,
          title: L.of(context).tasksTitle,
          items: ProjectContent.of(context).tasks,
        ),
      ],
    );
  }
}

class _ResultsTab extends StatelessWidget {
  const _ResultsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SectionCard(
          badge: L.of(context).resultsBadge,
          badgeColor: const Color(0xFF2C7BE5),
          title: L.of(context).expectedResultsTitle,
          items: ProjectContent.of(context).expectedResults,
        ),
        const SizedBox(height: 16),
        SectionCard(
          badge: L.of(context).valueBadge,
          badgeColor: const Color(0xFFF0A02C),
          title: L.of(context).practicalValueTitle,
          items: ProjectContent.of(context).practicalValue,
        ),
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  const _Paragraph({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.heading,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
        ),
      ],
    );
  }
}
