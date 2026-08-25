import wave
import math
import struct
import random

# Generate high quality 16-bit metal clang ricochet sound (ÇIINNGG!)
sample_rate = 44100
duration = 0.8
num_samples = int(sample_rate * duration)

with wave.open("/Users/yusufalikarpuz/Documents/yeni-oyun-projesi/sounds/metal_clang.wav", "w") as wav_file:
    wav_file.setnchannels(1)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    
    for i in range(num_samples):
        t = i / sample_rate
        # Metallic frequencies: 1250 Hz, 2800 Hz, 4600 Hz, 6200 Hz
        env = math.exp(-t * 9.0)
        
        sig = math.sin(2 * math.pi * 1250 * t) * 0.4
        sig += math.sin(2 * math.pi * 2840 * t) * 0.35
        sig += math.sin(2 * math.pi * 4650 * t) * 0.25
        sig += math.sin(2 * math.pi * 6300 * t) * 0.15
        
        # Initial sharp impact click
        if t < 0.015:
            sig += (random.random() * 2 - 1) * 0.8
            
        sample = int(sig * env * 28000)
        sample = max(-32768, min(32767, sample))
        wav_file.writeframes(struct.pack('<h', sample))

print("Created metal_clang.wav successfully!")
