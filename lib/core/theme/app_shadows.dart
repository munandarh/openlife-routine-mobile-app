import 'package:flutter/material.dart';

import 'package:openlife_routine/core/theme/app_colors.dart';

final class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> floating = <BoxShadow>[
    BoxShadow(color: Color(0x1F8EAA5E), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static final BoxDecoration card = BoxDecoration(
    color: AppColors.surface,
    border: Border.all(color: AppColors.border),
    borderRadius: BorderRadius.circular(24),
    boxShadow: soft,
  );
}
