import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension OpenLifeNavigation on BuildContext {
  /// Pops when there is a route behind this one, otherwise navigates to
  /// [fallback].
  ///
  /// A screen opened from a notification is entered with `go`, so it has no
  /// history behind it. Calling `pop` there throws
  /// `GoError: There is nothing to pop` and strands the user on a page they
  /// cannot leave — which is exactly what happened when a routine was deleted
  /// from a detail screen the reminder had opened.
  void popOrGo(String fallback) {
    if (canPop()) {
      pop();
      return;
    }
    go(fallback);
  }
}
