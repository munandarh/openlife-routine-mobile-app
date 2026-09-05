import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only product events: no network, personal identifiers or health claims.
class MeditationPreferences {
  MeditationPreferences([this._provided]);
  final SharedPreferencesAsync? _provided;
  SharedPreferencesAsync get _prefs => _provided ?? SharedPreferencesAsync();
  static Future<void> _eventWrites = Future<void>.value();
  Future<Set<String>> favorites() async =>
      (await _prefs.getStringList('meditation.favorites') ?? []).toSet();
  Future<void> saveFavorites(Set<String> ids) =>
      _prefs.setStringList('meditation.favorites', ids.toList());
  Future<bool> musicEnabled() async =>
      await _prefs.getBool('meditation.music') ?? true;
  Future<void> setMusic(bool value) =>
      _prefs.setBool('meditation.music', value);
  Future<double> musicVolume() async =>
      await _prefs.getDouble('meditation.volume') ?? 1.0;
  Future<void> setVolume(double value) =>
      _prefs.setDouble('meditation.volume', value.clamp(0.0, 1.0));
  Future<void> event(
    String name, [
    Map<String, Object?> properties = const {},
  ]) {
    final write = _eventWrites
        .then((_) async {
          final raw = await _prefs.getStringList('meditation.events') ?? [];
          raw.add(
            jsonEncode({
              'event': name,
              'at': DateTime.now().toIso8601String(),
              ...properties,
            }),
          );
          await _prefs.setStringList(
            'meditation.events',
            raw.skip(raw.length > 500 ? raw.length - 500 : 0).toList(),
          );
        })
        .catchError((Object _) {
          /* Optional diagnostics must not block a session. */
        });
    _eventWrites = write;
    return write;
  }
}
