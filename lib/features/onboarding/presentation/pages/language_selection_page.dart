import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openlife_routine/app/router/app_router.dart';
import 'package:openlife_routine/core/di/app_scope.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/core/theme/app_text_styles.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pageMargin),
          children: <Widget>[
            const _MiniHeader(),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(
                          AppRadius.extraLarge,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.language_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Choose your language',
                      style: AppTextStyles.pageTitle.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Pick the language you want to see first. You can change it later in settings.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _LanguageCard(
                      title: 'English',
                      subtitle: 'Default app language',
                      isSelected: _selectedLanguageCode == 'en',
                      onTap: () => _selectLanguage('en'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _LanguageCard(
                      title: 'Bahasa Indonesia',
                      subtitle: 'Bahasa utama untuk pengguna lokal',
                      isSelected: _selectedLanguageCode == 'id',
                      onTap: () => _selectLanguage('id'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: 'Continue',
              isLoading: _isSaving,
              onPressed: () => _continue(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniHeader extends StatelessWidget {
  const _MiniHeader();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'Language selection',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primarySoft : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.extraLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.extraLarge),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                ),
                child: Icon(
                  Icons.translate_outlined,
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
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
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
