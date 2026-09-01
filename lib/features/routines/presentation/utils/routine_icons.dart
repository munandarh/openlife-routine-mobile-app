import 'package:flutter/material.dart';

/// The icon override palette offered on the New/Edit Routine form.
///
/// Keys are stored in the database, so they must stay stable: rename a key only
/// with a migration. An unknown key resolves to null and the routine falls back
/// to its category default.
final class RoutineIcons {
  const RoutineIcons._();

  static const Map<String, IconData> byKey = <String, IconData>{
    'restaurant': Icons.restaurant_outlined,
    'water_drop': Icons.water_drop_outlined,
    'medication': Icons.medication_outlined,
    'vaccines': Icons.vaccines_outlined,
    'bedtime': Icons.bedtime_outlined,
    'fitness_center': Icons.fitness_center_outlined,
    'self_improvement': Icons.self_improvement_outlined,
    'directions_walk': Icons.directions_walk_outlined,
    'visibility': Icons.visibility_outlined,
    'local_cafe': Icons.local_cafe_outlined,
    'wb_sunny': Icons.wb_sunny_outlined,
    'star': Icons.star_outline_rounded,
  };

  static List<String> get keys => byKey.keys.toList(growable: false);

  static IconData? resolve(String? iconKey) {
    if (iconKey == null) {
      return null;
    }
    return byKey[iconKey];
  }
}
