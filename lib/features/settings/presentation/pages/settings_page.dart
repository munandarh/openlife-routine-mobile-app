import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/features/settings/data/services/export_import_service.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/icon_circle_button.dart';

/// The app's `filledButtonTheme` stretches buttons to full width for the
/// primary call to action, which makes a dialog's action row wrap and stack.
/// Dialog buttons opt out and size to their label.
final ButtonStyle _dialogButtonStyle = FilledButton.styleFrom(
  minimumSize: const Size(72, 40),
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        final TextTheme textTheme = Theme.of(context).textTheme;
        final AppLocalizations l10n = context.l10n;

        return CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              leadingWidth: 68,
              leading: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.pageMargin),
                child: Center(
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: context.palette.surfaceSoft,
                    child: const Icon(
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
              actions: <Widget>[
                IconCircleButton(
                  icon: Icons.notifications_none_rounded,
                  onPressed: () =>
                      context.push(OpenLifeRoute.notifications.path),
                ),
                const SizedBox(width: AppSpacing.pageMargin),
              ],
              pinned: true,
              backgroundColor: context.palette.background,
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
                        trailing: _themeLabel(l10n, state.themeMode),
                        onTap: () => _showThemePicker(context),
                      ),
                      _SettingsItemData(
                        icon: Icons.language_outlined,
                        title: l10n.languageSetting,
                        trailing: state.languageCode == 'id'
                            ? l10n.bahasaShort
                            : l10n.englishLang,
                        onTap: () => _showLanguagePicker(context),
                      ),
                      _SettingsItemData(
                        icon: Icons.motion_photos_off_outlined,
                        title: l10n.reducedMotionSetting,
                        subtitle: l10n.reducedMotionDescription,
                        toggleValue: state.reducedMotion,
                        onToggle: (bool value) {
                          context.read<SettingsBloc>().add(
                            SettingsReducedMotionChanged(value),
                          );
                        },
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
                          final ScaffoldMessengerState messenger =
                              ScaffoldMessenger.of(context);
                          final String message =
                              l10n.notificationPermissionRequested;
                          await AppScope.read(
                            context,
                          ).notificationService.requestPermissions();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(message),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
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
                        title: l10n.privacyData,
                        onTap: () => context.push(OpenLifeRoute.privacy.path),
                      ),
                      _SettingsItemData(
                        icon: Icons.code_outlined,
                        title: l10n.aboutOpenSourceSetting,
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

  static String _themeLabel(AppLocalizations l10n, String themeMode) {
    return switch (themeMode) {
      'dark' => l10n.darkTheme,
      'light' => l10n.lightTheme,
      _ => l10n.systemTheme,
    };
  }

  void _showThemePicker(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
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
                _ThemeOption(
                  icon: Icons.brightness_auto_outlined,
                  label: l10n.systemTheme,
                  mode: 'system',
                  parentContext: context,
                  sheetContext: sheetContext,
                ),
                _ThemeOption(
                  icon: Icons.light_mode_outlined,
                  label: l10n.lightTheme,
                  mode: 'light',
                  parentContext: context,
                  sheetContext: sheetContext,
                ),
                _ThemeOption(
                  icon: Icons.dark_mode_outlined,
                  label: l10n.darkTheme,
                  mode: 'dark',
                  parentContext: context,
                  sheetContext: sheetContext,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.large),
        ),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
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
    final AppLocalizations l10n = context.l10n;

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
            // Without this the backup can only be read on screen and
            // hand-selected, which is not a backup anyone would actually take.
            FilledButton(
              style: _dialogButtonStyle,
              onPressed: () async {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                await Clipboard.setData(ClipboardData(text: json));
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.copiedToClipboard),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(l10n.copyAction),
            ),
          ],
        );
      },
    );
  }

  void _showImportDialog(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
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
              style: _dialogButtonStyle,
              onPressed: () async {
                final String json = controller.text.trim();
                if (json.isEmpty) {
                  return;
                }

                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                final ExportImportService service = AppScope.read(
                  context,
                ).createExportImportService();

                try {
                  final int count = await service.importFromJson(json);
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.routinesImported(count)),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } on Exception catch (e) {
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.importFailed(e.toString())),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
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
    final AppLocalizations l10n = context.l10n;

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
              style: _dialogButtonStyle.copyWith(
                backgroundColor: const WidgetStatePropertyAll<Color>(
                  AppColors.danger,
                ),
              ),
              onPressed: () async {
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
                  context,
                );
                final ExportImportService service = AppScope.read(
                  context,
                ).createExportImportService();

                await service.resetAllData();
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.allDataReset),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(l10n.resetButton),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.mode,
    required this.parentContext,
    required this.sheetContext,
  });

  final IconData icon;
  final String label;
  final String mode;
  final BuildContext parentContext;
  final BuildContext sheetContext;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        parentContext.read<SettingsBloc>().add(SettingsThemeChanged(mode));
        Navigator.pop(sheetContext);
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
          ).textTheme.titleMedium?.copyWith(color: context.palette.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: context.palette.border),
          ),
          child: Column(
            children: items.map((_SettingsItemData item) {
              if (item.onToggle != null) {
                return SwitchListTile.adaptive(
                  secondary: Icon(item.icon, color: AppColors.primary),
                  title: Text(item.title),
                  subtitle: item.subtitle == null
                      ? null
                      : Text(item.subtitle!),
                  value: item.toggleValue ?? false,
                  onChanged: item.onToggle,
                );
              }

              return ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.title),
                subtitle: item.subtitle == null ? null : Text(item.subtitle!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (item.trailing != null)
                      Text(
                        item.trailing!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: item.trailingColor ?? context.palette.textSecondary,
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
    this.subtitle,
    this.trailing,
    this.trailingColor,
    this.onTap,
    this.toggleValue,
    this.onToggle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;

  /// Set both [toggleValue] and [onToggle] to render the row as a switch.
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
}
