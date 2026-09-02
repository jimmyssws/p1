# 🌦️ Dinamik Hava Durumu ve Gece Sisi Sistemi

**Tarih:** 2026-08-27  
**Geliştirici:** Hermes & Antigravity  
**Durum:** Aktif & Oyuna Entegre Edildi ✅  
**İlgili Scriptler:** `scripts/weather_controller.gd`, `scripts/main.gd`

---

## 🌟 1. Sisteme Genel Bakış
Miting alanındaki gerilimi ve atmosferi artırmak amacıyla Godot 4 motoru üzerinde **Dinamik Hacimsel Sis (Volumetric Fog)**, **Yağmur Döngüsü** ve **Işık Huzmesi Yönetimi** entegre edilmiştir.

Sistem, `scripts/main.gd` dosyasının `_ready()` fonksiyonunda `_setup_weather_system()` ile otomatik olarak sahneye yüklenir ve sahnedeki `WorldEnvironment` bileşeniyle anlık haberleşir.

---

## ⚙️ 2. Temel Mekanikler

### 🌫️ A. Dinamik Hacimsel Sis (Volumetric Fog)
- Sis yoğunluğu oyun akışına göre `0.0` ile `0.5` arasında pürüzsüz bir şekilde (lerp interpolasyonu ile) artar veya azalır.
- Yağmur başladığında görüş mesafesi daralır, koruma ve suikastçıların hareket alanı daha gergin bir havaya bürünür.

### 🌧️ B. Rastgele Yağmur Döngüsü
- `rain_check_interval` (5 saniye) periyodunda rastgele yağmur başlama ihtimali (`rain_chance = %30`) hesaplanır.
- Yağmur başladığında `GPUParticles3D` partikülleri devreye girer ve sis otomatik olarak yoğunlaşır.

### 💡 C. Projektör ve Işık Huzmesi Uyarlaması
- Miting meydanındaki projektörler ve sahne ışıkları, sisin yoğunluğuna göre parlaklıklarını ayarlar.
- Yoğun sis altında ışık huzmeleri (light beams) belirginleşirken doğrudan aydınlatma mesafesi dengelenir.

### 🌌 D. Gökyüzü ve Coşku Renk Geçişi
- Miting coşkusuna ve zaman faktörüne bağlı olarak `ProceduralSkyMaterial` renkleri dinamik olarak güncellenir.

---

## 📋 3. Gelecek Görevler & Testler
- [ ] Yağmur başladığında zemin ıslaklık shader'ını (Roughness düşürme) entegre et.
- [ ] Yağmur damlalarının mikrofon/hoparlör üzerinde parazit sesi çıkarmasını sağla.
- [ ] Şimşek çakma efektini (DirectionalLight anlık parlama) hava kontrolcüsüne ekle.

---

## 🎛️ 4. Menüden Hava Durumu Seçeneği & Kalıcılık (v0.06)
- **Arayüz Entegrasyonu:** Ana Menü (`scenes/menu.tscn`) içindeki **⚙️ SES & OYUN AYARLARI** paneline `Hava Durumu Seçeneği` açılır menüsü (`OptionButton`) eklendi.
- **Seçenekler:**
  - ☀️ **Güneşli / Açık Hava (`SUNNY`):** Temiz mavi skybox, sıcak altın sarısı `DirectionalLight3D`, sıfır/hafif sis, kapalı yağmur partikülleri.
  - 🌧️ **Yağmurlu / Sisli Hava (`RAINY`):** Sinematik gece/fırtına skybox'ı, `Volumetric Fog` (0.035), 3D yağmur partikülleri ve tok atmosfer ışığı.
- **Kalıcılık & Otomasyon:** Seçilen mod `Global.weather_type` değişkenine aktarılır ve `user://settings.cfg` içinde saklanır. `weather_controller.gd` sahne açılışında seçilen moda göre ortamı anında yapılandırır. Oyun içinde `R` tuşu ile modlar arasında anlık geçiş yapılabilir.

