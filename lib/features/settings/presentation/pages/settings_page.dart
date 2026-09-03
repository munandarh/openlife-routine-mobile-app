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
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/features/settings/data/services/export_import_service.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_event.dart';
import 'package:openlife_routine/features/settings/presentation/bloc/settings_state.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/navigation/openlife_app_bar.dart';

/// The app's `filledButtonTheme` stretches buttons to full width for the
/// primary call to action, which makes a dialog's action row wrap and stack.
/// Dialog buttons opt out and size to their label.
final ButtonStyle _dialogButtonStyle = FilledButton.styleFrom(
  minimumSize: const Size(72, 40),
  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  /// Null until the platform answers, and stays null if it cannot. The row
  /// then shows no value rather than claiming reminders are allowed.
  bool? _alertsAllowed;

  @override
  void initState() {
    super.initState();
    _refreshAlertStatus();
  }

  Future<void> _refreshAlertStatus() async {
    final bool? allowed = await AppScope.read(
      context,
    ).notificationService.areNotificationsEnabled();
    if (mounted) {
      setState(() => _alertsAllowed = allowed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (BuildContext context, SettingsState state) {
        final AppLocalizations l10n = context.l10n;

        return CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(child: OpenLifeAppBar.tab()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  AppSpacing.lg,
                  AppSpacing.pageMargin,
                  0,
                ),
                child: Text(l10n.settingsTitle, style: AppTextStyles.pageTitle),
              ),
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
                        toggleValue: state.reducedMotion,
                        onToggle: (bool value) {
                          context.read<SettingsBloc>().add(
                            SettingsReducedMotionChanged(value),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg - 2),
                  _SettingsSection(
                    title: l10n.notificationsSection,
                    items: <_SettingsItemData>[
                      _SettingsItemData(
                        icon: Icons.health_and_safety_outlined,
                        title: l10n.reminderHealthSetting,
                        onTap: () =>
                            context.push(OpenLifeRoute.reminderHealth.path),
                      ),
                      _SettingsItemData(
                        icon: Icons.notifications_active_outlined,
                        title: l10n.routineAlerts,
                        trailing: switch (_alertsAllowed) {
                          true => l10n.alertsAllowed,
                          false => l10n.alertsBlocked,
                          null => null,
                        },
                        trailingColor: _alertsAllowed == false
                            ? AppColors.danger
                            : null,
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
                          await _refreshAlertStatus();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg - 2),
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
                        trailingColor: AppColors.danger,
                        onTap: () => _showResetDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg - 2),
                  _SettingsSection(
                    title: l10n.aboutSection,
                    items: <_SettingsItemData>[
                      _SettingsItemData(
                        icon: Icons.shield_outlined,
                        title: l10n.privacyData,
                        onTap: () => context.push(OpenLifeRoute.privacy.path),
                      ),
                      _SettingsItemData(
                        icon: Icons.code_outlined,
                        title: l10n.openSourceSetting,
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

/// A labelled group of settings rows.
///
/// Rows are built by hand rather than with `ListTile`, because the mockup's
/// row is a 32px tinted icon container plus a 10px-padded line — a ListTile's
/// own minimum height and leading metrics push nine rows past the screen.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});

  final String title;
  final List<_SettingsItemData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.label.copyWith(
              letterSpacing: 1.1,
              color: context.palette.textMuted,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm - 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Column(
            children: <Widget>[
              for (int i = 0; i < items.length; i += 1)
                _SettingsRow(item: items[i], isLast: i == items.length - 1),
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item, required this.isLast});

  final _SettingsItemData item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color titleColor = item.trailingColor ?? context.palette.textPrimary;

    final Widget row = Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.palette.background),
              ),
            ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.palette.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(item.icon, size: 17, color: context.palette.primaryInk),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  item.title,
                  style: AppTextStyles.button.copyWith(
                    fontSize: 15,
                    color: titleColor,
                  ),
                ),
              ],
            ),
          ),
          if (item.onToggle != null)
            Switch.adaptive(
              value: item.toggleValue ?? false,
              onChanged: item.onToggle,
            )
          else ...<Widget>[
            if (item.trailing != null)
              Flexible(
                child: Text(
                  item.trailing!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyEmphasis.copyWith(
                    fontSize: 13,
                    color: item.trailingColor ?? context.palette.textSecondary,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.xs + 2),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.palette.iconMuted,
            ),
          ],
        ],
      ),
    );

    if (item.onTap == null) {
      return row;
    }
    return InkWell(onTap: item.onTap, child: row);
  }
}

class _SettingsItemData {
  const _SettingsItemData({
    required this.icon,
    required this.title,
    this.trailing,
    this.trailingColor,
    this.onTap,
    this.toggleValue,
    this.onToggle,
  });

  final IconData icon;
  final String title;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback? onTap;

  /// Set both [toggleValue] and [onToggle] to render the row as a switch.
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
}
