part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, ready, completed, skipped }

final class OnboardingState extends Equatable {
  const OnboardingState({
    required this.status,
    required this.pageIndex,
    required this.selectedLanguageCode,
    required this.totalPages,
    this.selectedTemplateId,
  });

  const OnboardingState.initial()
    : status = OnboardingStatus.initial,
      pageIndex = 0,
      selectedLanguageCode = 'en',
      totalPages = 4,
      selectedTemplateId = null;

  final OnboardingStatus status;
  final int pageIndex;
  final String selectedLanguageCode;
  final int totalPages;

  /// Starter template chosen on the last slide, or null for "start empty".
  final String? selectedTemplateId;

  bool get isLastPage => pageIndex == totalPages - 1;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? pageIndex,
    String? selectedLanguageCode,
    String? selectedTemplateId,
    bool clearSelectedTemplate = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      pageIndex: pageIndex ?? this.pageIndex,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      totalPages: totalPages,
      selectedTemplateId: clearSelectedTemplate
          ? null
          : selectedTemplateId ?? this.selectedTemplateId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    pageIndex,
    selectedLanguageCode,
    totalPages,
    selectedTemplateId,
  ];
}
