import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_shadows.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
import 'package:openlife_routine/l10n/app_localizations.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({
    this.onLanguageSelected,
    this.onContinue,
    super.key,
  });

  final Future<void> Function(BuildContext context, String languageCode)?
  onLanguageSelected;
  final VoidCallback? onContinue;

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String _selectedLanguageCode = 'en';
  bool _isSaving = false;

  void _selectLanguage(String languageCode) {
    setState(() => _selectedLanguageCode = languageCode);
  }

  Future<void> _continue() async {
    setState(() => _isSaving = true);
    try {
      if (widget.onLanguageSelected != null) {
        await widget.onLanguageSelected!(context, _selectedLanguageCode);
      } else {
        await AppScope.read(
          context,
        ).onboardingRepository.setPreferredLanguageCode(_selectedLanguageCode);
        if (!mounted) {
          return;
        }
        context.go(OpenLifeRoute.notificationPermission.path);
      }

      widget.onContinue?.call();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const _BrandRow(),
                  const SizedBox(height: AppSpacing.xxl),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: _GlobeBadge(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.chooseYourLanguage,
                            style: AppTextStyles.pageTitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.chooseLanguageDesc,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _LanguageCard(
                            code: 'EN',
                            title: l10n.englishLang,
                            subtitle: 'Default app language',
                            isSelected: _selectedLanguageCode == 'en',
                            onTap: () => _selectLanguage('en'),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _LanguageCard(
                            code: 'ID',
                            title: l10n.bahasaLang,
                            subtitle: 'Bahasa utama untuk pengguna lokal',
                            isSelected: _selectedLanguageCode == 'id',
                            onTap: () => _selectLanguage('id'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(
                    label: l10n.continueButton,
                    isLoading: _isSaving,
                    onPressed: () => _continue(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Same brand lockup the onboarding slides open with, so the first-run flow
/// reads as one screen sequence.
class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(Icons.spa_outlined, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Text(
          AppLocalizations.of(context)!.appTitle,
          style: AppTextStyles.cardTitle.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

/// A compact emblem instead of the large empty panel the page used to open
/// with: it marks the screen without leaving a big hollow block above the
/// title.
class _GlobeBadge extends StatelessWidget {
  const _GlobeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: const Icon(
        Icons.language_outlined,
        size: 28,
        color: AppColors.primary,
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.code,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  /// Two-letter language code shown in the leading tile (e.g. `EN`).
  final String code;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
        boxShadow: isSelected ? AppShadows.soft : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.large),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              // Keep the tile and the tick lined up with the title when the
              // subtitle wraps to a second line.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surface : AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Text(
                    code,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _SelectionTick(isSelected: isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionTick extends StatelessWidget {
  const _SelectionTick({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 1.5,
            ),
          ),
          child: isSelected
              ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
