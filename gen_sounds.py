import struct, math, random, os

sr = 22050
dir_path = r"C:\Users\yusuf\Documents\yeni-oyun-projesi\sounds"

def make_wav(path, samples, sr=22050):
    data = struct.pack('<' + 'h' * len(samples), *samples)
    with open(path, 'wb') as f:
        f.write(b'RIFF')
        f.write(struct.pack('<I', 36 + len(data)))
        f.write(b'WAVE')
        f.write(b'fmt ')
        f.write(struct.pack('<IHHIIHH', 16, 1, 1, sr, sr*2, 2, 16))
        f.write(b'data')
        f.write(struct.pack('<I', len(data)))
        f.write(data)

def clamp16(v):
    return max(-32767, min(32767, int(v * 32767)))

# HEARTBEAT
n = int(sr * 1.2)
hb = []
for i in range(n):
    t = i / sr
    v = 0.0
    if t < 0.12:
        v = math.sin(math.pi * t / 0.12) * math.exp(-t * 18) * 0.85
    if 0.18 <= t < 0.30:
        tt = t - 0.18
        v = math.sin(math.pi * tt / 0.12) * math.exp(-tt * 14) * 0.55
    hb.append(clamp16(v))
make_wav(os.path.join(dir_path, "heartbeat.wav"), hb)
print("OK: heartbeat.wav")

# FOOTSTEP
n = int(sr * 0.20)
fs = []
for i in range(n):
    t = i / sr
    freq = 80 * math.exp(-t * 25)
    v = math.sin(2 * math.pi * freq * t) * math.exp(-t * 30) * 0.6
    noise = (random.uniform(-1, 1)) * 0.12 * math.exp(-t * 40)
    fs.append(clamp16(v + noise))
make_wav(os.path.join(dir_path, "footstep.wav"), fs)
print("OK: footstep.wav")

# HIT IMPACT (taser/bıçak çarpma hissi)
n = int(sr * 0.18)
hit = []
for i in range(n):
    t = i / sr
    v = math.sin(2 * math.pi * 440 * t) * 0.4
    v += math.sin(2 * math.pi * 880 * t) * 0.3
    v += math.sin(2 * math.pi * 220 * t) * 0.2
    v *= math.exp(-t * 22)
    hit.append(clamp16(v))
make_wav(os.path.join(dir_path, "hit_impact.wav"), hit)
print("OK: hit_impact.wav")

print("\nTUM SESLER TAMAM")
