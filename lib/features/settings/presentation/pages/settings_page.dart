import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/settings/data/services/export_import_service.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        final TextTheme textTheme = Theme.of(context).textTheme;

        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leadingWidth: 68,
              leading: const Padding(
                padding: EdgeInsets.only(left: AppSpacing.pageMargin),
                child: Center(
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.surfaceSoft,
                    child: Icon(
                      Icons.settings_outlined,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              title: Text(
                l10n.settingsTitle,
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                ),
              ),
              actions: const <Widget>[
                IconCircleButton(
                  icon: Icons.notifications_none_rounded,
                ),
                SizedBox(width: AppSpacing.pageMargin),
              ],
              pinned: true,
              backgroundColor: AppColors.background,
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.xl,
                AppSpacing.pageMargin,
                120,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  _SettingsSection(
                    title: l10n.preferencesSection,
                    items: <_SettingsItemData>[
                      _SettingsItemData(
                        icon: Icons.palette_outlined,
                        title: l10n.themeSetting,
                        trailing: state.themeMode == 'system'
                            ? l10n.systemTheme
                            : state.themeMode == 'dark'
                            ? l10n.darkTheme
                            : l10n.lightTheme,
                        onTap: () => _showThemePicker(context),
                      ),
                      _SettingsItemData(
                        icon: Icons.language_outlined,
                        title: l10n.languageSetting,
                        trailing: state.languageCode == 'id'
                            ? l10n.bahasaLang
                            : l10n.englishLang,
                        onTap: () => _showLanguagePicker(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SettingsSection(
                    title: l10n.notificationsSection,
                    items: <_SettingsItemData>[
                      _SettingsItemData(
                        icon: Icons.notifications_active_outlined,
                        title: l10n.routineAlerts,
                        onTap: () async {
                          await AppScope.read(
                            context,
                          ).notificationService.requestPermissions();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notification permission requested.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SettingsSection(
                    title: l10n.dataSection,
                    items: <_SettingsItemData>[
                      _SettingsItemData(
                        icon: Icons.file_upload_outlined,
                        title: l10n.exportSetting,
                        trailing: l10n.exportJson,
                        onTap: () => _exportData(context),
                      ),
                      _SettingsItemData(
                        icon: Icons.file_download_outlined,
                        title: l10n.importSetting,
                        trailing: l10n.exportJson,
                        onTap: () => _showImportDialog(context),
                      ),
                      _SettingsItemData(
                        icon: Icons.delete_outline_rounded,
                        title: l10n.resetSetting,
                        trailing: l10n.resetDestructive,
                        trailingColor: AppColors.danger,
                        onTap: () => _showResetDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _SettingsSection(
                    title: l10n.privacySection,
                    items: <_SettingsItemData>[
                      _SettingsItemData(
                        icon: Icons.shield_outlined,
                        title: l10n.privacySetting,
                        onTap: () => context.push(OpenLifeRoute.privacy.path),
                      ),
                      _SettingsItemData(
                        icon: Icons.code_outlined,
                        title: l10n.aboutSetting,
                        onTap: () => context.push(OpenLifeRoute.about.path),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThemePicker(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.chooseTheme,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Icon(Icons.brightness_auto_outlined),
                title: Text(l10n.systemTheme),
                onTap: () {
                  context.read<SettingsBloc>().add(
                    const SettingsThemeChanged('system'),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode_outlined),
                title: Text(l10n.lightTheme),
                onTap: () {
                  context.read<SettingsBloc>().add(
                    const SettingsThemeChanged('light'),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: Text(l10n.darkTheme),
                onTap: () {
                  context.read<SettingsBloc>().add(
                    const SettingsThemeChanged('dark'),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                l10n.chooseLanguage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: const Text('🇬🇧'),
                title: Text(l10n.englishLang),
                onTap: () {
                  context.read<SettingsBloc>().add(
                    const SettingsLanguageChanged('en'),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Text('🇮🇩'),
                title: Text(l10n.bahasaLang),
                onTap: () {
                  context.read<SettingsBloc>().add(
                    const SettingsLanguageChanged('id'),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context) async {
    final ExportImportService service = AppScope.read(
      context,
    ).createExportImportService();
    final String json = await service.exportToJson();

    if (context.mounted) {
      _showExportResultDialog(context, json);
    }
  }

  void _showExportResultDialog(BuildContext context, String json) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.exportData),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: SingleChildScrollView(
              child: SelectableText(
                json,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.closeAction),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.importData),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: l10n.pasteJsonHint,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              onPressed: () async {
                final String json = controller.text.trim();
                if (json.isEmpty) {
                  return;
                }
                try {
                  final ExportImportService service = AppScope.read(
                    context,
                  ).createExportImportService();
                  final int count = await service.importFromJson(json);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$count routines imported.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } on Exception catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Import failed: $e'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: Text(l10n.importAction),
            ),
          ],
        );
      },
    );
  }

  void _showResetDialog(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.resetAllData),
          content: Text(l10n.resetWarning),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancelAction),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () async {
                final ExportImportService service = AppScope.read(
                  context,
                ).createExportImportService();
                await service.resetAllData();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All data has been reset.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: Text(l10n.resetButton),
            ),
          ],
        );
      },
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
          ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: items.map((_SettingsItemData item) {
              return ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (item.trailing != null)
                      Text(
                        item.trailing!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: item.trailingColor ?? AppColors.textSecondary,
                        ),
                      ),
                    if (item.onTap != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ],
                ),
                onTap: item.onTap,
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
    required this.icon,
    required this.title,
    this.trailing,
    this.trailingColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;
}
