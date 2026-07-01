import 'package:flutter/widgets.dart';
import 'package:openlife_routine/core/di/app_dependencies.dart';

class AppScope extends InheritedWidget {
  const AppScope({required this.dependencies, required super.child, super.key});

  final AppDependencies dependencies;

  static AppDependencies of(BuildContext context) {
    final AppScope? scope = context
        .dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing in the widget tree.');
    return scope!.dependencies;
  }

  static AppDependencies read(BuildContext context) {
    final AppScope? scope =
        context.getElementForInheritedWidgetOfExactType<AppScope>()?.widget
            as AppScope?;
    assert(scope != null, 'AppScope is missing in the widget tree.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return dependencies != oldWidget.dependencies;
  }
}
