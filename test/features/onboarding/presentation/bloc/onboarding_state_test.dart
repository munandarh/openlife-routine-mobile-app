import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() {
  group('OnboardingState.initial', () {
    test('totalPages is 4 (3 slides + 1 starter template screen)', () {
      const OnboardingState state = OnboardingState.initial();
      expect(state.totalPages, 4);
    });

    test('isLastPage is true on the new last page (index 3)', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 3,
        selectedLanguageCode: 'en',
        totalPages: 4,
      );
      expect(state.isLastPage, true);
    });

    test('isLastPage is false on intermediate pages', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 1,
        selectedLanguageCode: 'en',
        totalPages: 4,
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
