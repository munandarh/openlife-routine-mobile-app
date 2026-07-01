import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openlife_routine/features/templates/domain/repositories/template_repository.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_bloc.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_event.dart';
import 'package:openlife_routine/features/templates/presentation/bloc/template_state.dart';

void main() {
  late TemplateRepository repository;

  setUp(() {
    repository = TemplateRepository();
  });

  group('TemplateBloc', () {
    blocTest<TemplateBloc, TemplateState>(
      'emits success with templates when loaded',
      build: () => TemplateBloc(repository: repository),
      act: (TemplateBloc bloc) => bloc.add(const TemplatesLoaded()),
      verify: (TemplateBloc bloc) {
        expect(bloc.state.status, TemplateStatus.success);
        expect(bloc.state.templates.length, 5);
      },
    );

    blocTest<TemplateBloc, TemplateState>(
      'initial state is loading',
      build: () => TemplateBloc(repository: repository),
      verify: (TemplateBloc bloc) {
        expect(bloc.state.status, TemplateStatus.initial);
        expect(bloc.state.templates, isEmpty);
      },
    );
  });
}
