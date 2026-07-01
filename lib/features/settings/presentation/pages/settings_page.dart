import 'package:flutter/material.dart';

import 'package:openlife_routine/shared/widgets/app_placeholder_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPlaceholderPage(
      title: 'Settings',
      description:
          'Theme, language, notifications, and backup controls start here.',
      ctaLabel: 'Prepare preferences',
      icon: Icons.settings_outlined,
    );
  }
}
