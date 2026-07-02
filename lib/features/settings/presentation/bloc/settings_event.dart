import 'package:equatable/equatable.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class SettingsStarted extends SettingsEvent {
  const SettingsStarted();
}

final class SettingsThemeChanged extends SettingsEvent {
  const SettingsThemeChanged(this.mode);

  final String mode;

  @override
  List<Object?> get props => <Object?>[mode];
}

final class SettingsLanguageChanged extends SettingsEvent {
  const SettingsLanguageChanged(this.code);

  final String code;

  @override
  List<Object?> get props => <Object?>[code];
}
