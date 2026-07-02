part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, ready, completed, skipped }

final class OnboardingState extends Equatable {
  const OnboardingState({
    required this.status,
    required this.pageIndex,
    required this.selectedLanguageCode,
    required this.totalPages,
  });

  const OnboardingState.initial()
    : status = OnboardingStatus.initial,
      pageIndex = 0,
      selectedLanguageCode = 'en',
      totalPages = 4;

  final OnboardingStatus status;
  final int pageIndex;
  final String selectedLanguageCode;
  final int totalPages;

  bool get isLastPage => pageIndex == totalPages - 1;

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? pageIndex,
    String? selectedLanguageCode,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      pageIndex: pageIndex ?? this.pageIndex,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      totalPages: totalPages,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    pageIndex,
    selectedLanguageCode,
    totalPages,
  ];
}
