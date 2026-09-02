# 🧠 Hermes Master Godot 4 Game Development Skill Pack

Bu belge, Hermes'in Godot 4.x motorunda profesyonel seviyede oyun geliştirmesi, kod yazması ve hata ayıklaması için hazırlanmış **Master Beceri ve Kural Kütüphanesidir**.

---

## 🏗️ 1. Temel GDScript 2.0 Standartları
- **Statik Tiplendirme:** Tüm değişkenler ve fonksiyon dönüş tipleri belirtilmelidir (`var health: float = 100.0`, `func take_damage(amount: float) -> void:`).
- **Node Referansları:** Sahnedeki düğümlere `@onready var` ile bağlanılır. Eğer düğüm opsiyonel ise `get_node_or_null()` veya `find_child()` kullanılır.
- **Sinyaller (Signals):** Sahneler arası gevşek bağlılık için `signal event_triggered(data)` tanımlanır ve `Callable(self, "_on_event")` ile bağlanır.

---

## 🌫️ 2. Volumetric Render, Atmosfer ve Işık Mimarisi
- **Volumetric Fog:** Godot 4'te ışık huzmeleri ve sis için `WorldEnvironment.environment.volumetric_fog_enabled = true` aktif edilmelidir.
  - `volumetric_fog_density`: 0.03 - 0.06 arası.
  - `volumetric_fog_albedo`: Color(0.6, 0.7, 0.85).
  - `volumetric_fog_emission_energy`: 0.5 - 1.0 arası.
- **Işıklandırma:** Gündüz için `DirectionalLight3D` enerjisi 1.0 - 1.5, fırtına/gece için 0.2 - 0.4 seviyesine çekilmelidir.
- **Projektör Huzmeleri (SpotLights):** Sisin içinden parlayan projektörler için `light_energy` 4.0 - 8.0 yapılmalı ve `volumetric_fog` açık olmalıdır.

---

## 🌧️ 3. Bağımsız Partikül ve VFX Mimarisi (Self-Contained Particles)
- Bir partikül efekti (yağmur, kıvılcım, toz, şimşek) üretirken dışarıdan dosya beklemek yerine GDScript içinde sıfırdan oluşturulur:
  1. `var p = GPUParticles3D.new()` veya `CPUParticles3D.new()`
  2. `var mat = ParticleProcessMaterial.new()` ile hız, yön, yayılım ve yerçekimi ayarlanır.
  3. `var mesh = QuadMesh.new()` veya `BoxMesh.new()` ile `draw_pass_1` tanımlanır.
  4. Sahneye `add_child(p)` ile eklenir ve `p.emitting = true` yapılır.

---

## 🔌 4. Sahneye ve Ana Döngüye Uçtan Uca Enjeksiyon
- Yeni bir sistem kontrolcüsü yazıldığında (`scripts/weather_controller.gd` vb.):
  - `scripts/main.gd` dosyasında `_setup_...()` fonksiyonu oluşturulur.
  - `_ready()` içinde otomatik olarak başlatılır.
  - Asla sadece dosya yazılıp bırakılmaz; sahne hiyerarşisine eklenir.

---

## 🕹️ 5. Canlı Test Kısayolları (Interactive Keybindings)
- Geliştirilen her yeni özelliğin `_unhandled_input(event)` fonksiyonuna test tuşları konulur:
  - `R`: Yağmur aç/kapat
  - `F`: Sis yoğunluğu değiştir
  - `T`: Şimşek / Fırtına tetikle
  - Konsola `print("🌦️ [Test] ...")` ile bilgi basılır.

---

## 🛠️ 6. Dosya Düzenleme Döngüsü (Pair-Programming Disiplini)
1. **Araştır:** `search_code(path, query)` ile ilgili fonksiyonu ve satırı tam olarak bul.
2. **Uygula:** `replace_in_file(path, target_text, replacement_text)` ile cerrahi olarak kodu güncelle.
3. **Senkronize Et:** `execute_shell(command="git status; git push", cwd="godot")` ile diske yazılan kodu GitHub'a aktar.
4. **Raporla:** Yusuf Bey'e neyin nerede nasıl değiştiğini net bir Türkçe özetle anlat.
