# 🎮 Hermes Godot 4 Geliştirme ve Mimari Kuralları (Master Guide)

Bu belge, Hermes'in Miting Oyunu (Godot 4) projesinde kod yazarken ve yeni mekanikler geliştirirken **HARFİYEN UYMASI GEREKEN ALTIN KURALLARDIR**:

---

## 🌟 1. Bağımsız ve Kendi Kendine Yeten Kodlar (Self-Contained Architecture)
- Yeni bir görsel veya efekt yazarken (örneğin yağmur, sis, lazer, anons ışığı), asla dışarıdan atanması zorunlu `@export var scene: PackedScene` bırakıp kodu çalıştırmazlık yapma!
- Gerekli partikülleri (`GPUParticles3D`), materyalleri (`StandardMaterial3D`, `ParticleProcessMaterial`) ve mesh'leri (`QuadMesh`, `BoxMesh`) **doğrudan GDScript içinde kod ile oluştur ve başlat.**

---

## 🌫️ 2. Godot 4 Render ve Atmosfer Standartları
- Godot 4'te gerçekçi sis ve ışık huzmeleri için her zaman **`volumetric_fog_enabled = true`** yapılmalıdır (eski `fog_enabled` tek başına yeterli değildir).
- Yoğunluk değeri `0.03` ile `0.06` arasında tutulmalı, `volumetric_fog_albedo` ve `volumetric_fog_emission_energy` değerleri atmosferle uyumlu ayarlanmalıdır.
- Sahnedeki `WorldEnvironment` düğümünü bulurken `get_tree().root.find_child("WorldEnvironment", true, false)` fonksiyonunu kullanarak sahne hiyerarşisi değişse bile güvenle bul.

---

## 🔌 3. Oyuna Tam Entegrasyon (End-to-End Injection)
- Bir script yazdığında (`scripts/yeni_sistem.gd`), işi sadece dosyayı kaydetmekle bitirme!
- Mutlaka `scripts/main.gd` dosyasını incele, `_ready()` fonksiyonunun içine `_setup_yeni_sistem()` metodunu ekleyerek sahneye `add_child()` ile bağla.

---

## 🕹️ 4. Canlı Test Tuşları (Interactive Debug Keybindings)
- Geliştirdiğin her yeni mekaniğe (`_unhandled_input` içinde) Yusuf Bey'in klavyeden anında test edebileceği kısayol tuşları ekle (Örneğin: Yağmur için `R`, Sis için `F`, Test için `T`).
- Konsola (`print`) neyin açılıp kapandığını Türkçe olarak yazdır.
