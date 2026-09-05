import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Serialized commands prevent a slow load from restarting music after pause/exit.
class MeditationAudio extends ChangeNotifier {
  AudioPlayer? _player;
  Future<void> _queue = Future<void>.value();
  bool _closed = false;
  bool available = true;
  bool enabled = true;
  double volume = .35;

  Future<void> _run(Future<void> Function() action) {
    _queue = _queue.then((_) async {
      if (_closed) return;
      try {
        await action();
      } catch (_) {
        available = false;
        if (!_closed) notifyListeners();
      }
    });
    return _queue;
  }

  Future<void> start(String score) => _run(() async {
    _player ??= AudioPlayer();
    await _player!.setReleaseMode(ReleaseMode.loop);
    await _player!.play(AssetSource('audio/$score.m4a'), volume: 0);
    if (!enabled) {
      await _player!.pause();
      return;
    }
    await _fade(volume);
  });

  Future<void> _fade(double target) async {
    final start = _player?.volume ?? 0;
    for (var i = 1; i <= 8 && !_closed; i++) {
      await _player?.setVolume(start + (target - start) * i / 8);
      await Future<void>.delayed(const Duration(milliseconds: 35));
    }
  }

  Future<void> pause() => _run(() async {
    await _fade(0);
    await _player?.pause();
  });
  Future<void> resume() => _run(() async {
    if (!enabled) return;
    await _player?.resume();
    await _fade(volume);
  });
  Future<void> setEnabled(bool value, {required bool paused}) async {
    enabled = value;
    notifyListeners();
    if (value && !paused) {
      await resume();
    } else {
      await pause();
    }
  }

  Future<void> setVolume(double value) {
    volume = value.clamp(0, 1);
    notifyListeners();
    return _run(() async {
      if (enabled) await _player?.setVolume(volume);
    });
  }

  @override
  void dispose() {
    _closed = true;
    unawaited(
      _queue.whenComplete(() async {
        await _player?.dispose();
      }),
    );
    super.dispose();
  }
}
