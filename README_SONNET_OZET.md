# 🎮 MİTİNG & SUİKASTÇI OYUNU — PROJE & SİSTEM ÖZETİ (SONNET İÇİN)

Bu dosya projeyi devralan yapay zeka asistanı (Sonnet) için projedeki tüm mimariyi, dosyaları ve son özellikleri tek bir yerde özetler.

---

## 📁 1. Projedeki Yeni ve Kritik Dosyalar

* **`global.gd` (Autoload / Singleton):**
  * `Global.network_mode` ("HOST" / "JOIN")
  * `Global.join_ip` (Varsayılan: `100.68.81.79` veya `127.0.0.1`)
  * `Global.master_volume` (0.0 - 1.0 arası ses kontrolü)

* **`menu.tscn` / `menu.gd` (Ana Menü & Ayarlar):**
  * 👑 **Oda Kur (Host):** Port 9999 üzerinden sunucu başlatır.
  * 🚀 **Masaüstü Sunucuya Bağlan:** `100.68.81.79:9999` dedicated sunucuya tek tıkla bağlanır.
  * 🎮 **IP ile Katıl:** Özel IP girişi.
  * ⚙️ **Ayarlar Paneli:** Canlı `HSlider` ile Master ses düzeyini (%0 - %100) ayarlar.

* **`minimap.gd` (Sol Üst Taktik Radar):**
  * Meydandaki oyuncuları, dron kamerasının canlı konumunu ve görev bölgelerini çizer.

* **`web_portal/` (Tarayıcıdan Oynama & Tanıtım Portalı - Port 8085):**
  * `server.js`: Node.js Express sunucusu.
  * `index.html`: Tanıtım sitesi, rol kartları, ses test paneli.
  * `play.html`: 3D WebGL Three.js tarayıcı oyun motoru (`http://localhost:8085/play.html`).

* **`sounds/` (16-Bit Organik Ses Kütüphanesi):**
  * `gunshot.wav`: Tok barutlu 9mm tabanca sesi.
  * `taser.wav`: 60Hz düşük elektrik arkı/kıvılcım sesi.
  * `scan.wav`: Yumuşak çift tonlu havalimanı telsiz tınısı.
  * `knife.wav`: Tok çelik savrulma efekti.
  * `task_complete.wav`: C-E-G-C armonik başarı akoru.
  * `crowd_ambient.wav`: Sıcak miting uğultusu loop'u.
  * `silly_chatter_*.wav`: Yumuşak ve derinden NPC mırıltıları (-16 dB).

---

## 🎯 2. Karakterler & Yetenek Mekanikleri

### 🏛️ BAŞKAN (F1 ile Test):
* **3 Aşamalı Görev Rotası:**
  1. 🎙️ Kürsü Konuşması (3 Müjde Checkpoint'i, %25-%50-%75)
  2. 🤝 Halkla Selamlaşma
  3. 📰 Basın Çadırı Röportajı
* **Yetenekler:**
  * `[1] 🏃 Adrenalin Deparı` (%80 hız artışı)
  * `[2] 📢 Halka Sesleniş` (Kalabalığı etrafına toplar)
  * `[3] 💼 Çelik Çanta Kalkanı` (1 suikast darbesini tamamen bloklar ve kaçış hızı verir)
  * `[4] 🍵 Rize Çayı Fırlat` (Kalabalığa çay atar, siviller kapmak için etten duvar örer)

### 🛡️ KORUMALAR (F2 ile Koruma 1, 2, 3 Geçişi):
* **`[1]` Tuşu:** Her korumada her zaman **⚡ Taser** (7.5m menzil, 4.5 sn şok).
* **`[2]` Tuşu:** Koruma sınıfına göre otomatik değişir:
  * **Koruma 1:** `📡 Absürt Dedektör` (Sivillerden komik eşyalar, suikastçıdan silah çıkar).
  * **Koruma 2:** `🚁 Dron Gönder` (Gökyüzü kamerası: `[WASD]` uçuş, `[Space/E]` yüksel, `[Q/Ctrl]` alçal, `[Shift]` turbo).
  * **Koruma 3:** `📢 'Herkes Dursun!' Megafonu` (%85 sivil donar ve korumaya döner; kaçan kişi doğrudan suikastçıdır).

### 🗡️ SUIKASTÇI (F3 ile Test):
* **Sosyal Gizlilik:** Silahı 3. şahısta görünmezdir, tamamen masum sivil gibi gezer.
* **`[C] Tuşu`:** Sivil Taklidi (Miting dinleme pozu, kalabalıkla bir olur).
* **`[WC Kabini]`:** Portatif tuvalete yaklaşıp `[Sol Tık]` yaparak takım elbise rengini değiştirir (Kılık değiştirme).
* **`[1] 🔪 Bıçak` & `[2] 🔫 Tabanca`:**
  * Ateş ettiğinde veya vurduğunda 22m kalabalık çığlıklarla kaçışır!
  * Silah **3. şahısta elinde açığa çıkar** (Dron ve korumalar silahı görür).
  * **`[G] Tuşu`:** Suikastçı silahı yere atarak elini temizler ve tekrar masum sivile döner!
* **`[3] 📢 İzdiham Çıkar`:** Turnikelerdeki kalabalığı sahneye hücum ettirir.

---

## ⏱️ 3. Maç Süresi & Meydan
* Maç süresi **3 Dakika (180 saniye)**.
* Meydanda **65 canlı sivil NPC** organik olarak dolaşır ve WC kuyruğuna girer.
* Dronun havadan görüşünü taktiksel olarak kesen **7 dev gölgeli çınar ağacı** bulunur.
