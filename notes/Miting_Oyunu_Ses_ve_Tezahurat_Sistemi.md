# Miting Oyunu – Dinamik Ses ve Tezahürat Sistemi

## 1. Giriş
Bu belge, **Godot 4** tabanlı *Miting Oyunu* projemizde, miting alanındaki kalabalığın coşkusuna göre ses yoğunluğunu ve megafon/hoparlör yankısını dinamik olarak yöneten `CrowdAudioController.gd` script mimarisini tanımlar.

---

## 2. Araştırma Özeti
### 2.1 Godot 4 – AudioBus ve Efektler
| Özellik | Açıklama | Kullanım Örneği |
|---------|----------|-----------------|
| **AudioBus** | Ses kanallarını gruplamak ve ortak efektler uygulamak için kullanılır. | `AudioServer.get_bus_index("CrowdBus")` → tüm kalabalık sesleri bu bus’a yönlendir.
| **Reverb** | Ortam yankısını taklit eder. `AudioEffectReverb` ile yansıma süresi, difüziyon ve dampening ayarlanabilir. | Kalabalık yoğunluğu arttıkça `reverb_room_size` ve `reverb_damping` artırılır.
| **LowPass Filter** | Düşük frekans geçişi, uzak seslerin boğuklaşmasını sağlar. `AudioEffectLowPassFilter` ile cutoff frekansı kontrol edilir. | Megafon sesinin uzaklaştırılması için `cutoff_hz` değeri dinamik olarak düşürülür.
| **PitchShift** | Sesin perdesini değiştirerek coşku seviyesini vurgular. | Kalabalık enerjisi yüksek olduğunda hafif bir **up‑pitch** uygulanır.

### 2.2 Kalabalık Tezahürat Sistemleri
* **Procedural Audio** – Tek bir ses kaynağını (ör. “rah!”) rastgele zaman aralıklarıyla çalarak kalabalık sesini taklit eder.
* **AudioStreamRandomPitch** – Aynı ses dosyasının farklı pitch değerleriyle çalınması, çeşitlilik katar.
* **Spatial Audio** – Hoparlör/megafon konumuna göre sesin 3D konumlandırılması, dinleyicinin konumuna göre ses şiddeti ve gecikme ayarlanır.
* **Dynamic Volume Curves** – Kalabalık yoğunluğu (`crowd_mood`) bir **Curve** (Godot `Curve` resource) üzerinden geçerek ses şiddeti, reverb ve low‑pass değerlerini otomatik olarak belirler.

---

## 3. `CrowdAudioController.gd` Mimari Tasarımı
```gdscript
# CrowdAudioController.gd
extends Node3D

# === NODE HİYERARŞİSİ ===
# CrowdAudioController (Node3D)
# ├─ AudioStreamPlayer3D   -> megafon_ses (AudioStream = megaphone.wav)
# ├─ AudioStreamPlayer3D   -> crowd_chant (AudioStream = chant.wav, random_pitch = true)
# └─ AudioBus ("CrowdBus") – Reverb, LowPass, PitchShift efektleri

# === DİNAMİK PARAMETRELER ===
@export var crowd_mood: float = 0.0          # 0.0 (sakin) – 1.0 (tam coşku)
@export var reverb_curve: Curve               # reverb_room_size vs mood
@export var lowpass_curve: Curve               # cutoff_hz vs mood
@export var volume_curve: Curve                # bus volume vs mood
@export var chant_interval_range: Vector2 = Vector2(2.0, 6.0) # saniye

# === INTERNAL ===
var _next_chant_time: float = 0.0
var _bus_index: int

func _ready() -> void:
    _bus_index = AudioServer.get_bus_index("CrowdBus")
    _apply_mood_parameters()
    _schedule_next_chant()

func _process(delta: float) -> void:
    _next_chant_time -= delta
    if _next_chant_time <= 0.0:
        _play_crowd_chant()
        _schedule_next_chant()

# ---- PUBLIC API ----
func set_crowd_mood(value: float) -> void:
    crowd_mood = clamp(value, 0.0, 1.0)
    _apply_mood_parameters()

# ---- PRIVATE HELPERS ----
func _apply_mood_parameters() -> void:
    # Volume (bus level)
    var vol_db = linear_to_db(volume_curve.interpolate_baked(crowd_mood))
    AudioServer.set_bus_volume_db(_bus_index, vol_db)

    # Reverb
    var rev = AudioServer.get_bus_effect(_bus_index, 0) as AudioEffectReverb
    rev.room_size = reverb_curve.interpolate_baked(crowd_mood)
    rev.damping = lerp(0.2, 0.8, crowd_mood)

    # LowPass
    var lp = AudioServer.get_bus_effect(_bus_index, 1) as AudioEffectLowPassFilter
    lp.cutoff_hz = lowpass_curve.interpolate_baked(crowd_mood)

    # PitchShift (optional for megaphone)
    var ps = AudioServer.get_bus_effect(_bus_index, 2) as AudioEffectPitchShift
    ps.pitch_scale = lerp(1.0, 1.15, crowd_mood)

func _schedule_next_chant() -> void:
    var interval = randf_range(chant_interval_range.x, chant_interval_range.y)
    _next_chant_time = interval * lerp(1.5, 0.5, crowd_mood) # coşku arttıkça daha sık çalar

func _play_crowd_chant() -> void:
    $crowd_chant.play()
```

### Açıklamalar
1. **AudioBus (CrowdBus)** – Proje ayarlarından `Audio > Buses` sekmesinde `CrowdBus` oluşturulur ve aşağıdaki efektler eklenir:
   * `AudioEffectReverb` (index 0)
   * `AudioEffectLowPassFilter` (index 1)
   * `AudioEffectPitchShift` (index 2)
2. **Curve Resources** – `reverb_curve`, `lowpass_curve` ve `volume_curve` **Curve** dosyaları (`res://curves/…`) olarak hazırlanır; her biri `crowd_mood` (0‑1) ekseninde değer döndürür.
3. **Kalabalık Mood Güncellemesi** – Oyun içinde bir **MoodManager** (ör. miting konuşması, skandal, hava durumu) `CrowdAudioController.set_crowd_mood()` metodunu çağırır.
4. **Tezahürat Çalma** – `AudioStreamPlayer3D` `crowd_chant` rastgele pitch ve zaman aralıklarıyla çalar; 3D konumu megafon/ hoparlör konumuna göre ayarlanır.
5. **Megafon Anonsu** – `megaphone.wav` aynı bus’a yönlendirilir, böylece reverb ve low‑pass aynı anda uygulanır.

---

## 4. Entegrasyon Adımları
1. **Audio Bus Oluştur** → `Project Settings > Audio > Buses` → `CrowdBus` ekle.
2. **Efektleri Ekle** → Reverb, LowPass, PitchShift sırasıyla ekle.
3. **Curve Dosyalarını Hazırla** → `res://curves/volume_curve.tres` vb.
4. **Node Hiyerarşisini Sahneye Ekleyin** → `CrowdAudioController.tscn` içinde script’i atayın.
5. **MoodManager** → Kalabalık mood değerini gerçek zamanlı olarak güncelleyin.

---

## 5. Test & Debug
| Test Senaryosu | Beklenen Sonuç |
|----------------|----------------|
| **Sakin** (`mood = 0.0`) | Düşük ses, hafif reverb, yüksek cutoff (temiz ses). |
| **Yoğun** (`mood = 1.0`) | Yüksek ses, büyük oda yankısı, düşük cutoff (boğuk, kalabalık hissi). |
| **Ani Skandal** → Mood aniden `0.8` | Anons sesi yükselir, reverb artar, tezahürat sıklığı artar. |

---

## 6. İleri Geliştirme Fikirleri
* **Ses Katmanları** – Farklı grup (ör. gençler, yaşlılar) için ayrı `AudioBus`lar.
* **Procedural Speech Synthesis** – AI‑tabanlı anons metinlerini sesli olarak üret.
* **VR Spatial Audio** – VR destekli mitingde gerçekçi konumlandırma.

---

*Bu belge, ses sisteminin temel mimarisini ve entegrasyon adımlarını kapsar. Geliştirme sırasında ortaya çıkan yeni gereksinimler için `CrowdAudioController` sınıfını genişletmekten çekinmeyin.*
