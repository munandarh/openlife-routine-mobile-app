import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_audio.dart';
import 'package:openlife_routine/features/meditate/data/services/meditation_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockSharedPreferencesAsync extends Mock implements SharedPreferencesAsync {}

class FakeSource extends Fake implements Source {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(ReleaseMode.loop);
    registerFallbackValue(MeditationAudio.audioContext);
    registerFallbackValue(FakeSource());
  });

  group('MeditationAudio', () {
    late MockAudioPlayer mockPlayer;
    late MeditationAudio audio;

    setUp(() {
      mockPlayer = MockAudioPlayer();
      when(() => mockPlayer.setAudioContext(any())).thenAnswer((_) async {});
      when(() => mockPlayer.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => mockPlayer.setVolume(any())).thenAnswer((_) async {});
      when(
        () => mockPlayer.play(
          any(),
          volume: any(named: 'volume'),
          balance: any(named: 'balance'),
          ctx: any(named: 'ctx'),
          position: any(named: 'position'),
          mode: any(named: 'mode'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockPlayer.pause()).thenAnswer((_) async {});
      when(() => mockPlayer.resume()).thenAnswer((_) async {});
      when(() => mockPlayer.dispose()).thenAnswer((_) async {});

      audio = MeditationAudio(mockPlayer);
    });

    tearDown(() {
      audio.dispose();
    });

    test('initializes with full default volume (1.0) and enabled', () {
      expect(audio.volume, 1.0);
      expect(audio.enabled, true);
      expect(audio.available, true);
    });

    test('audioContext configures iOS playback category and Android media stream', () {
      final ctx = MeditationAudio.audioContext;
      expect(ctx.iOS.category, AVAudioSessionCategory.playback);
      expect(ctx.android.usageType, AndroidUsageType.media);
      expect(ctx.android.contentType, AndroidContentType.music);
      expect(ctx.android.audioFocus, AndroidAudioFocus.gain);
    });

    test('start plays directly at current volume and configures audio context', () async {
      await audio.start('forest_stream_flow');

      verify(() => mockPlayer.setAudioContext(any())).called(1);
      verify(() => mockPlayer.setReleaseMode(ReleaseMode.loop)).called(1);
      verify(() => mockPlayer.setVolume(1.0)).called(1);
      verify(
        () => mockPlayer.play(
          any(
            that: isA<AssetSource>().having(
              (s) => s.path,
              'path',
              'audio/forest_stream_flow.m4a',
            ),
          ),
          volume: 1.0,
        ),
      ).called(1);
    });

    test('setVolume clamps between 0.0 and 1.0 and notifies listeners', () async {
      var notified = 0;
      audio.addListener(() => notified++);

      await audio.setVolume(0.75);
      expect(audio.volume, 0.75);
      expect(notified, 1);
      verify(() => mockPlayer.setVolume(0.75)).called(1);

      await audio.setVolume(1.5);
      expect(audio.volume, 1.0);

      await audio.setVolume(-0.2);
      expect(audio.volume, 0.0);
    });

    test('pause and resume control player without volume fading delays', () async {
      await audio.pause();
      verify(() => mockPlayer.pause()).called(1);

      await audio.resume();
      verify(() => mockPlayer.setVolume(1.0)).called(1);
      verify(() => mockPlayer.resume()).called(1);
    });

    test('setEnabled pauses when disabled and resumes when enabled', () async {
      await audio.setEnabled(false, paused: false);
      expect(audio.enabled, false);
      verify(() => mockPlayer.pause()).called(1);

      await audio.setEnabled(true, paused: false);
      expect(audio.enabled, true);
      verify(() => mockPlayer.resume()).called(1);
    });
  });

  group('MeditationPreferences volume', () {
    late MockSharedPreferencesAsync prefs;
    late Map<String, Object> storage;

    setUp(() {
      storage = {};
      prefs = MockSharedPreferencesAsync();
      when(() => prefs.getDouble(any())).thenAnswer(
        (i) async => storage[i.positionalArguments[0]] as double?,
      );
      when(() => prefs.setDouble(any(), any())).thenAnswer((i) async {
        storage[i.positionalArguments[0] as String] =
            i.positionalArguments[1] as double;
      });
    });

    test('defaults to 1.0 when unset and persists volume correctly', () async {
      final mp = MeditationPreferences(prefs);
      expect(await mp.musicVolume(), 1.0);

      await mp.setVolume(0.8);
      expect(await mp.musicVolume(), 0.8);

      // Clamp test
      await mp.setVolume(1.5);
      expect(await mp.musicVolume(), 1.0);
    });
  });
}
