import 'package:flutter/material.dart';

import 'package:openlife_routine/shared/widgets/app_placeholder_page.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderPage(
      title: 'Insights',
      description:
          'Weekly progress and streak summaries are staged after the core routine flow.',
      ctaLabel: 'Keep MVP focused',
      icon: Icons.insights_outlined,
    );
  }
}
