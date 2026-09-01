import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() {
  group('OnboardingState.initial', () {
    test('totalPages covers the four PRD onboarding slides', () {
      const OnboardingState state = OnboardingState.initial();
      expect(state.totalPages, 4);
    });

    test('starts with no starter template chosen', () {
      const OnboardingState state = OnboardingState.initial();
      expect(state.selectedTemplateId, isNull);
    });

    test('isLastPage is true on the last page (index 3)', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 3,
        totalPages: 4,
      );
      expect(state.isLastPage, true);
    });

    test('isLastPage is false on intermediate pages', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 1,
        totalPages: 4,
      );
      expect(state.isLastPage, false);
    });

    test('copyWith can clear the template back to start-empty', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 3,
        totalPages: 4,
        selectedTemplateId: 'morning',
      );

      expect(state.copyWith(selectedTemplateId: 'sleep').selectedTemplateId,
          'sleep');
      expect(state.copyWith(clearSelectedTemplate: true).selectedTemplateId,
          isNull);
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
