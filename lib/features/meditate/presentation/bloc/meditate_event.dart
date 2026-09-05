import 'package:equatable/equatable.dart';

sealed class MeditateEvent extends Equatable {
  const MeditateEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class MeditateStarted extends MeditateEvent {
  const MeditateStarted();
}

final class MeditateRefreshRequested extends MeditateEvent {
  const MeditateRefreshRequested();
}
