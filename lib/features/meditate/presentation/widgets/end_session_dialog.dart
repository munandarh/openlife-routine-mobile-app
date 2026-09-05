import 'package:flutter/material.dart';
import 'package:openlife_routine/core/localization/l10n_extensions.dart';
import 'package:openlife_routine/core/theme/app_palette.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';

class EndSessionDialog extends StatelessWidget {
  const EndSessionDialog({super.key, this.message, this.continueLabel});

  final String? message;
  final String? continueLabel;

  static Future<bool?> show(
    BuildContext context, {
    String? message,
    String? continueLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) =>
          EndSessionDialog(message: message, continueLabel: continueLabel),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      backgroundColor: context.palette.surface,
      title: Text(
        l10n.endSessionDialogTitle,
        style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
      ),
      content: Text(
        message ?? l10n.endSessionDialogMessage,
        style: AppTextStyles.body.copyWith(
          color: context.palette.textSecondary,
          fontSize: 14,
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            continueLabel ?? l10n.keepBreathingAction,
            style: AppTextStyles.button.copyWith(
              color: context.palette.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(
            l10n.endSessionAction,
            style: AppTextStyles.button.copyWith(
              color: context.palette.dangerInk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
