import 'package:equatable/equatable.dart';

sealed class InsightsEvent extends Equatable {
  const InsightsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class InsightsStarted extends InsightsEvent {
  const InsightsStarted();
}
