import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() {
  group('OnboardingState.initial', () {
    test('totalPages is 3', () {
      const OnboardingState state = OnboardingState.initial();
      expect(state.totalPages, 3);
    });

    test('isLastPage is true on the last page (index 2)', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 2,
        selectedLanguageCode: 'en',
        totalPages: 3,
      );
      expect(state.isLastPage, true);
    });

    test('isLastPage is false on intermediate pages', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 1,
        selectedLanguageCode: 'en',
        totalPages: 3,
      );
      expect(state.isLastPage, false);
    });
  });

  group('OnboardingState events', () {
    test('OnboardingBackPressed is a valid event', () {
      const OnboardingBackPressed event = OnboardingBackPressed();
      expect(event, isA<OnboardingEvent>());
    });

    test('OnboardingNextPressed is a valid event', () {
      const OnboardingNextPressed event = OnboardingNextPressed();
      expect(event, isA<OnboardingEvent>());
    });
  });
}
