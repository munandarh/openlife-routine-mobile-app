import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openlife_routine/features/templates/domain/entities/routine_template.dart';
import 'package:openlife_routine/features/templates/domain/repositories/template_repository.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_event.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_state.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  TemplateBloc({required TemplateRepository repository})
    : _repository = repository,
      super(const TemplateState()) {
    on<TemplatesLoaded>(_onTemplatesLoaded);
    on<TemplateApplied>(_onTemplateApplied);
  }

  final TemplateRepository _repository;

  Future<void> _onTemplatesLoaded(
    TemplatesLoaded event,
    Emitter<TemplateState> emit,
  ) async {
    emit(
      state.copyWith(status: TemplateStatus.loading, clearErrorMessage: true),
    );

    try {
      final List<RoutineTemplate> templates = await _repository.getTemplates();
      emit(
        state.copyWith(status: TemplateStatus.success, templates: templates),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: TemplateStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTemplateApplied(
    TemplateApplied event,
    Emitter<TemplateState> emit,
  ) async {
    // Template application is handled by the UI layer
    // which reads the template from state and creates routines.
    emit(state.copyWith(status: TemplateStatus.success));
  }
}
