# Meditation QA evidence

Recorded on the Android 16 arm64 emulator (1080 × 2400), using the release APK. Screenshots show actual app state, not generated mockups.

- `home.png`: real Meditate home and category entry points.
- `home-library-footer.png`: library/quick-start/history area.
- `setup.png`: Anxiety setup; selectable pace and fixed duration.
- `player.png`, `paused.png`: Anxiety running and paused states.
- `focus-library.png`: distinct Focus collection, including the saved-practice control.
- `focus-player.png`: One Clear Thing, with its own 10-minute duration, blue scenery, text guidance and soundscape controls.
- `meditation-motion.mp4`: eight-second recording of the running Focus player after Resume; silent screen capture, not an audio demonstration.

Navigation observed: Meditate → Anxiety setup → player → Pause/Resume; category Focus → favorite → One Clear Thing setup → Begin practice → distinct player → Pause/Resume → exit confirmation. Runtime media.player output confirmed looped stereo AAC playback at 24 kHz, default gain 0.35, and paused playback with gain zero after Pause. This does not certify subjective audio quality, physical speaker behavior, or measured 60 fps.

Automated coverage includes every general practice route and quick duration; 320dp at 200% text in English and Indonesian, light/dark themes and reduced motion; exact Anxiety timing and occurrence linkage. See GATES.md for final command fingerprints and docs/meditation-implementation.md for OS/beta release validation still required.

Captures precede the final contextual exit-copy adjustment; that adjustment is included in the final tested APK.
