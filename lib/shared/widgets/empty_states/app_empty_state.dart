import 'package:flutter/material.dart';
import 'package:openlife_routine/core/theme/app_colors.dart';
import 'package:openlife_routine/core/theme/app_radius.dart';
import 'package:openlife_routine/core/theme/app_spacing.dart';
import 'package:openlife_routine/shared/widgets/buttons/primary_button.dart';

class AppEmptyState extends StatefulWidget {
  const AppEmptyState({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    this.onPressed,
    super.key,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  State<AppEmptyState> createState() => _AppEmptyStateState();
}

class _AppEmptyStateState extends State<AppEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _PulsingIcon(icon: widget.icon),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.title,
                style: textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.description,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(label: widget.buttonLabel, onPressed: widget.onPressed),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({required this.icon});

  final IconData icon;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (BuildContext context, Widget? child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primarySoft,
            foregroundColor: AppColors.primary,
            child: Icon(widget.icon, size: 28),
          ),
        );
      },
    );
  }
}
