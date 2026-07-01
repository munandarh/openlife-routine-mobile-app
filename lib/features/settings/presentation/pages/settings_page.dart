import 'package:flutter/material.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.pageMargin,
        AppSpacing.pageMargin,
        120,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.surfaceSoft,
              child: Icon(Icons.person_outline, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text('Settings', style: textTheme.headlineMedium)),
            const IconCircleButton(icon: Icons.notifications_none_rounded),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
        const _SettingsSection(
          title: 'Profile',
          items: <_SettingsItemData>[
            _SettingsItemData(
              title: 'Account Details',
              subtitle: 'Manage personal info',
              icon: Icons.person_outline,
              iconColor: AppColors.primary,
              iconBackground: AppColors.primarySoft,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SettingsSection(
          title: 'Preferences',
          items: <_SettingsItemData>[
            _SettingsItemData(
              title: 'Theme',
              trailing: 'System',
              icon: Icons.palette_outlined,
            ),
            _SettingsItemData(
              title: 'Language',
              trailing: 'English',
              icon: Icons.language_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        _SettingsSection(
          title: 'Notifications',
          items: <_SettingsItemData>[
            _SettingsItemData(
              title: 'Routine alerts',
              subtitle: 'Allow reminders and exact alarm scheduling',
              icon: Icons.notifications_none_rounded,
              onTap: () async {
                await AppScope.read(
                  context,
                ).notificationService.requestPermissions();
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notification permissions request sent.'),
                  ),
                );
              },
            ),
            const _SettingsItemData(
              title: 'Email updates',
              trailing: 'Off',
              icon: Icons.mail_outline,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SettingsSection(
          title: 'Data',
          items: <_SettingsItemData>[
            _SettingsItemData(
              title: 'Export routines',
              icon: Icons.download_outlined,
            ),
            _SettingsItemData(
              title: 'Backup status',
              trailing: 'Local only',
              icon: Icons.upload_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const _SettingsSection(
          title: 'Privacy',
          items: <_SettingsItemData>[
            _SettingsItemData(
              title: 'Privacy & data',
              icon: Icons.shield_outlined,
            ),
            _SettingsItemData(
              title: 'About open source',
              icon: Icons.code_outlined,
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.map((_SettingsItemData item) {
              final bool isLast = item == items.last;
              return Column(
                children: <Widget>[
                  ListTile(
                    onTap: item.onTap == null
                        ? null
                        : () {
                            item.onTap!.call();
                          },
                    leading: CircleAvatar(
                      backgroundColor:
                          item.iconBackground ?? AppColors.surfaceSoft,
                      foregroundColor:
                          item.iconColor ?? AppColors.textSecondary,
                      child: Icon(item.icon),
                    ),
                    title: Text(item.title),
                    subtitle: item.subtitle == null
                        ? null
                        : Text(item.subtitle!),
                    trailing: item.trailing == null
                        ? const Icon(Icons.chevron_right_rounded)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                item.trailing!,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.border),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.title,
    required this.icon,
    this.subtitle,
    this.trailing,
    this.iconBackground,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final IconData icon;
  final Color? iconBackground;
  final Color? iconColor;
  final Future<void> Function()? onTap;
}
