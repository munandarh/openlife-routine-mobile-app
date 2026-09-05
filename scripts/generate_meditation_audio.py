"""Original 48-second ambient compositions, no external recordings/samples.
Periodic harmonic beds and staggered soft bell notes; seamless PCM endpoints.
Regenerate with Python + numpy + ffmpeg. Assets carry the project's license.
"""
from pathlib import Path
import numpy as np
import subprocess
import tempfile
import wave

RATE, SECONDS = 24000, 48
out = Path(__file__).resolve().parents[1] / 'assets/audio'
out.mkdir(exist_ok=True)
t = np.arange(RATE * SECONDS) / RATE
scores = {
    'still_waters': ([48, 55, 60, 64, 67], [72, 76, 79, 76, 74, 72]),
    'clear_sky': ([50, 57, 62, 66, 69], [74, 78, 81, 85, 81, 78]),
    'first_light': ([53, 60, 65, 69, 72], [77, 81, 84, 81, 79, 77]),
    'moonlit_rest': ([45, 52, 57, 60, 64], [69, 72, 76, 72, 71, 69]),
    'soft_tide': ([46, 53, 58, 62, 65], [70, 74, 77, 74, 72, 70]),
    'warm_ground': ([43, 50, 55, 59, 62], [67, 71, 74, 71, 69, 67]),
}
for name, (chord, melody) in scores.items():
    channels = []
    for channel in range(2):
        mix = np.zeros_like(t)
        for i, note in enumerate(chord):
            # Whole oscillations over the loop prevent discontinuity.
            freq = round((440 * 2 ** ((note - 69) / 12)) * SECONDS) / SECONDS
            phase = i * .7 + channel * .15
            swell = .62 + .38 * np.sin(2 * np.pi * t / SECONDS + i) ** 2
            mix += .028 * swell * (np.sin(2*np.pi*freq*t+phase) + .18*np.sin(4*np.pi*freq*t+phase))
        for i, note in enumerate(melody):
            age = (t - i * 8 - channel * .08) % SECONDS
            env = (1 - np.exp(-age / .32)) * np.exp(-age / 2.8)
            freq = 440 * 2 ** ((note - 69) / 12)
            mix += .042 * env * (np.sin(2*np.pi*freq*age) + .2*np.sin(2*np.pi*freq*2*age))
        channels.append(mix)
    pcm = (np.stack(channels, axis=1).clip(-.9,.9) * 32767).astype('<i2')
    with tempfile.NamedTemporaryFile(suffix='.wav') as tmp:
        with wave.open(tmp.name, 'wb') as f:
            f.setnchannels(2); f.setsampwidth(2); f.setframerate(RATE); f.writeframes(pcm.tobytes())
        subprocess.run(['ffmpeg','-y','-loglevel','error','-i',tmp.name,'-c:a','aac','-b:a','96k',str(out/f'{name}.m4a')],check=True)
print('Generated six original ambient scores')
