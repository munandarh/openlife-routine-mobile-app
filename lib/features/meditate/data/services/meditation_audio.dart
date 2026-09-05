import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Serialized commands prevent a slow load from restarting music after pause/exit.
class MeditationAudio extends ChangeNotifier {
  MeditationAudio([this._player]);

  AudioPlayer? _player;
  Future<void> _queue = Future<void>.value();
  bool _closed = false;
  bool available = true;
  bool enabled = true;
  double volume = 1.0;

  static final AudioContext audioContext = AudioContext(
    iOS: AudioContextIOS(
      category: AVAudioSessionCategory.playback,
      options: const {},
    ),
    android: const AudioContextAndroid(
      isSpeakerphoneOn: false,
      stayAwake: true,
      contentType: AndroidContentType.music,
      usageType: AndroidUsageType.media,
      audioFocus: AndroidAudioFocus.gain,
    ),
  );

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

  Future<void> _setupPlayer() async {
    _player ??= AudioPlayer();
    try {
      await AudioPlayer.global.setAudioContext(audioContext);
    } catch (_) {
      // Global AudioContext configuration is ignored if unsupported or in tests.
    }
    try {
      await _player!.setAudioContext(audioContext);
    } catch (_) {
      // AudioContext configuration is ignored if unsupported or in tests.
    }
  }

  Future<void> start(String score) => _run(() async {
    await _setupPlayer();
    await _player!.setReleaseMode(ReleaseMode.loop);
    await _player!.setVolume(volume);
    await _player!.play(AssetSource('audio/$score.m4a'), volume: volume);
    if (!enabled) {
      await _player!.pause();
    }
  });

  Future<void> pause() => _run(() async {
    await _player?.pause();
  });

  Future<void> resume() => _run(() async {
    if (!enabled) return;
    await _player?.setVolume(volume);
    await _player?.resume();
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
    volume = value.clamp(0.0, 1.0);
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
