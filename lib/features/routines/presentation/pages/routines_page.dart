import 'package:flutter/material.dart';

import 'package:openlife_routine/shared/widgets/app_placeholder_page.dart';

class RoutinesPage extends StatelessWidget {
  const RoutinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderPage(
      title: 'Routines',
      description: 'Routine CRUD and templates will live in this flow.',
      ctaLabel: 'Open routine foundation',
      icon: Icons.calendar_today_outlined,
    );
  }
}
