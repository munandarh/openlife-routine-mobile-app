import 'package:equatable/equatable.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';

enum TemplateStatus { initial, loading, success, failure }

class TemplateState extends Equatable {
  const TemplateState({
    this.status = TemplateStatus.initial,
    this.templates = const <RoutineTemplate>[],
    this.errorMessage,
  });

  final TemplateStatus status;
  final List<RoutineTemplate> templates;
  final String? errorMessage;

  TemplateState copyWith({
    TemplateStatus? status,
    List<RoutineTemplate>? templates,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return TemplateState(
      status: status ?? this.status,
      templates: templates ?? this.templates,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, templates, errorMessage];
}
