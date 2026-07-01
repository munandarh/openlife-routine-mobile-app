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

final class OnboardingLanguageSelected extends OnboardingEvent {
  const OnboardingLanguageSelected(this.languageCode);

  final String languageCode;

  @override
  List<Object?> get props => <Object?>[languageCode];
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
