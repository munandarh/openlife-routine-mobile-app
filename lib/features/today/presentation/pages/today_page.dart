import 'package:flutter/material.dart';

import 'package:openlife_routine/shared/widgets/app_placeholder_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderPage(
      title: 'Today',
      description:
          'Daily progress, week selector, and routine checklist start here.',
      ctaLabel: 'Start Sprint 1 UI',
      icon: Icons.today_outlined,
    );
  }
}
