part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

final class OnboardingPageChanged extends OnboardingEvent {
  const OnboardingPageChanged(this.pageIndex);

  final int pageIndex;

  @override
  List<Object?> get props => <Object?>[pageIndex];
}

/// Emitted when the user picks a starter template on the final step, or
/// clears the pick to start empty.
final class OnboardingTemplateSelected extends OnboardingEvent {
  const OnboardingTemplateSelected(this.templateId);

  /// Null means "start empty".
  final String? templateId;

  @override
  List<Object?> get props => <Object?>[templateId];
}

final class OnboardingNextPressed extends OnboardingEvent {
  const OnboardingNextPressed();
}

final class OnboardingBackPressed extends OnboardingEvent {
  const OnboardingBackPressed();
}

final class OnboardingSkipped extends OnboardingEvent {
  const OnboardingSkipped();
}

final class OnboardingCompleted extends OnboardingEvent {
  const OnboardingCompleted();
}
