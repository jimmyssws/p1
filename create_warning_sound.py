import wave
import math
import struct

sample_rate = 44100
duration = 0.5
num_samples = int(sample_rate * duration)

with wave.open("/Users/yusufalikarpuz/Documents/yeni-oyun-projesi/sounds/sniper_warning.wav", "w") as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    
    for i in range(num_samples):
        t = i / sample_rate
        # Rapid dual pulse beep (880 Hz / 1760 Hz)
        pulse = 1.0 if (t % 0.15) < 0.08 else 0.0
        sig = math.sin(2 * math.pi * 1400 * t) * pulse * 0.5
        sample = int(sig * 26000)
        sample = max(-32768, min(32767, sample))
        wav_file.writeframes(struct.pack('<h', sample))

print("Created sniper_warning.wav successfully!")
