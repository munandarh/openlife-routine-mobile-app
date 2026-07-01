import 'package:equatable/equatable.dart';

sealed class TemplateEvent extends Equatable {
  const TemplateEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class TemplatesLoaded extends TemplateEvent {
  const TemplatesLoaded();
}

final class TemplateApplied extends TemplateEvent {
  const TemplateApplied(this.templateId);

  final String templateId;

  @override
  List<Object?> get props => <Object?>[templateId];
}
