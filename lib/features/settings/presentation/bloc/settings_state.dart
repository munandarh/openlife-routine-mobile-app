import 'package:equatable/equatable.dart';

enum SettingsLoadStatus { initial, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.status = SettingsLoadStatus.initial,
    this.themeMode = 'system',
    this.languageCode = 'en',
    this.errorMessage,
  });

  final SettingsLoadStatus status;
  final String themeMode;
  final String languageCode;
  final String? errorMessage;

  SettingsState copyWith({
    SettingsLoadStatus? status,
    String? themeMode,
    String? languageCode,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return SettingsState(
      status: status ?? this.status,
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    themeMode,
    languageCode,
    errorMessage,
  ];
}
