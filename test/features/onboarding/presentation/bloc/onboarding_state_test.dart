import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/onboarding/presentation/bloc/onboarding_bloc.dart';

void main() {
  group('OnboardingState.initial', () {
    test('totalPages is 4', () {
      const OnboardingState state = OnboardingState.initial();
      expect(state.totalPages, 4);
    });

    test('no starter template is selected by default', () {
      const OnboardingState state = OnboardingState.initial();
      expect(state.selectedTemplateId, isNull);
    });

    test('isLastPage is true on the last page (index 3)', () {
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

  group('OnboardingState.copyWith', () {
    test('clearSelectedTemplate resets the starter choice', () {
      const OnboardingState state = OnboardingState(
        status: OnboardingStatus.ready,
        pageIndex: 3,
        selectedLanguageCode: 'en',
        totalPages: 4,
        selectedTemplateId: 'morning',
      );

      expect(state.copyWith(clearSelectedTemplate: true).selectedTemplateId,
          isNull);
      expect(
        state.copyWith(selectedTemplateId: 'sleep').selectedTemplateId,
        'sleep',
      );
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

    test('OnboardingTemplateSelected carries the template id', () {
      const OnboardingTemplateSelected event = OnboardingTemplateSelected(
        'morning',
      );
      expect(event, isA<OnboardingEvent>());
      expect(event.templateId, 'morning');
    });
  });
}
