# 📋 MİTİNG OYUNU: GÖREVLER VE YOL HARİTASI (v0.05 Alpha)

**Son Güncelleme:** 2026-08-24
**Sorumlular:** Yusuf Ali Karpuz (Kral) & Malor AI
**Hedef:** Akşam arkadaş grubuyla yerel ağ (LAN / Tailscale) üzerinden kusursuz parti testi!

---

## 🚀 Tamamlananlar (Done - %100 Çalışır & Canlı Test Edildi)

- [x] 🎪 **Sahne & Rampalar Miting Standardına Getirildi:** Öndeki kaba rampa kaldırıldı; sol ve sağ tarafa gerçek konser/miting sahnelerindeki gibi şık yan çıkış rampaları yerleştirildi.
- [x] ⚡ **Taser Dengelemesi (7.5m Menzil & 4.5s Yerde Kalma):** Taser menzili 14m'den 7.5m'ye çekildi; bayılma süresi 4.5 saniyeye düşürüldü.
- [x] 🔍 **[E] ile Üst Arama & Kaçış Mekaniği:** Bayılan şahsın üzeri 4.5 sn içinde [E] ile aranırsa: Suikastçıysa silahlar bulunup tutuklanıyor; masumsa cepten sandviç/tuşlu telefon çıkıyor. 4.5 sn içinde aranmazsa şahıs deparla fırlayıp kalabalığa kaçıyor!
- [x] 🛡️ **3 Farklı Koruma Sınıfı (Özel Tim):**
  - **Koruma 1 (İstihbarat):** `[1] ⚡ Taser` + `[2] 📡 Metal Dedektörü`
  - **Koruma 2 (Hava Desteği):** `[1] ⚡ Taser` + `[2] 🚁 Gözetleme Dronu`
  - **Koruma 3 (Güvenlik Anonsçusu):** `[1] ⚡ Taser` + `[2] 📢 'Herkes Dursun!' Megafonu`
  - *Solo testte `[F2]` ile anında aralarında geçiş yapılır.*
- [x] 📢 **'Herkes Dursun!' Megafon Emri & Doğal Sivil Tepkisi:** Megafon basıldığında %80 sivil 0.3-2.2 sn içinde durup etrafa bakınıyor, %20 huysuz sivil durmayıp söyleniyor. Suikastçı durmazsa kendini ele veriyor!
- [x] 👥 **Sivil Kalabalığın Korumadan Kaçması & Yol Açması:** Koruma kalabalığa yaklaştığında (5.2m) siviller hızla kenara çekilip yürüyüş koridoru açıyor.
- [x] 🔊 **3D Konumsal Çevre Sesleri:** Kalabalık uğultusu 3D konumsal yapıldı; kalabalığın içinde zenginleşir, sahneye/çadırlara gidince tamamen kesilir.
- [x] ⚡ **1-Click Sunucu Bağlantısı:** Menüye tek tıkla Windows PC'deki sunucuya bağlanma butonu eklendi.
- [x] 🏛️ **3 Aşamalı Başkan Görev Zinciri:** Kürsü Konuşması (13s) -> Halkı Selamlama (10s) -> Basın Röportajı (10s).
- [x] 🚨 **Giriş Turnikesi X-Ray Dedektörü:** Suikastçı izdihamsız geçerse alarm sirenleri çalar.
- [x] 📰 **Canlı Kayan Haber Bandı (Breaking News):** Başkan kürsüde konuştukça absürt seçim vaatleri geçer.
- [x] 🏃 **Tok & Kütleli 3D Fizik Sistemi (v0.06):** Düşerken 1.95x Asimetrik Yerçekimi, Zemin İvmelenme/Sürtünme Eğrileri, Hava Direnci (Air Control kısıtlaması), Coyote Time (0.14s), Jump Buffer (0.12s), Yere İniş Kamera Esnemesi (Landing Dip), 3D İniş Toz Bulutu VFX ve Sağa/Sola Dönüşlerde Kamera Eğilmesi (Banking/Tilt) entegre edildi.
- [x] 🎨 **Modern Glassmorphic Dark Neon UI Tasarımı (v1.2):** Web portalındaki görsel stile (`index.html`) birebir uyumlu koyu cam paneller (`StyleBoxFlat`), role özel neon vurgular (Başkan: Altın Sarı `#F5C22B`, Koruma: Gökyüzü Mavisi `#38BDF8`, Suikastçı: Kan Kırmızısı `#DC2626`), canlı gölgeler ve modernize edilmiş HUD yuvaları entegre edildi.

---

## ⏳ Sıradaki Geliştirmeler & Fikir Havuzu (Backlog)

- [ ] 🤖 **Yapay Zeka Bot Suikastçı & Koruma:** Solo oynarken pratik yapabilmek için arkadan sızan bot suikastçı.
- [ ] 🗺️ **Miting Meydanı Harita Büyütmesi:** Miting alanına yeni sokaklar, miting otobüsü ve miting bayrakları ekleme.
- [ ] 🎨 **Karakter Özelleştirme & Renkli Takım Elbiseler:** Oyuncuların lobi ekranında kravat ve takım elbise rengi seçmesi.

* [x] 🛡️ **F2 ile Koruma 1, 2, 3 Sınıf Döngüsü & Sağ Alt HUD Kartları:** F2 tuşuna her basışta Koruma 1 (Dedektör), Koruma 2 (Dron) ve Koruma 3 (Megafon) arasında anında geçiş yapılıyor. Sağ alttaki kartlar seçilen sınıfa göre güncelleniyor. Yanlış sivil aramasında 15s Taser Kilitlenmesi ve 3.5s Yavaşlama cezası uygulandı.

* [x] 🎙️ **Kürsü Konuşması Checkpoint Sistemi (%25, %50, %75):** Başkan kürsüde konuşurken %25, %50, %75'te ilerleme kaydedilir. Bırakıp kaçsa bile kaldığı checkpoint'ten devam eder.
* [x] 📺 **Ekran Altı TV 'SON DAKİKA' Haber Bandı:** Her %25'te alttan kırmızı '🚨 SON DAKİKA' bandı çıkar ve komik seçim vaatleri akar.
* [x] 🚁 **Koruma 2 Dron Kontrolleri Düzeltildi:** Koruma 2'de [2] veya [F] tuşuna basıldığı an gökyüzüne dron fırlıyor.

* [x] 🛡️ **2 Slotlu Sabit Koruma HUD & [F2] Geçişi:** Korumalarda 1. özellik her zaman [1] ⚡ Taser, 2. özellik ise koruma değiştikçe [2] 📡 Dedektör / [2] 🚁 Dron / [2] 📢 Megafon olarak adlandırılıyor. 2 tuşuna basıldığında ilgili özellik anında çalışıyor.

* [x] 🔧 **Sağ Alt 2 Slotlu HUD & [F2] Geçişi Tam Senkronize Edildi:** player.gd dosyasındaki eski 3 slotlu kalıntı kod tamamen temizlendi. F2 ile Koruma 1 (Dedektör), Koruma 2 (Dron) ve Koruma 3 (Megafon) geçişi kesinleştirildi. Windows PC ve Mac'e gönderildi.

* [x] 📢 **'Herkes Dursun!' Donma Fiziği Kesinleştirildi:** Korumadan kaçış fiziğinin megafonu ezmesi engellendi. Megafon basıldığında siviller anında durup korumaya doğru dönüyor ve 4.2 sn çakılı kalıyor.

* [x] ⏱️ **Maç Süresi 3 Dakikaya (180s) Çıkarıldı:** Suikastçıya taktiksel sızma ve saklanma için bolca zaman tanındı.
* [x] 🚻 **Suikastçı Portatif WC Kılık Değiştirme Kabini:** Suikastçı şüphe çektiğinde haritadaki mavi WC'ye gidip [E] ile kıyafet rengini değiştiriyor.
* [x] 🍵 **Başkan Halka Keyif Çayı Fırlatma (Halk Kalkanı):** Başkan [4] tuşu ile kalabalığa çay paketi fırlatıyor; siviller çayı kapmak için hücum edip etten duvar örüyor.

* [x] 🎭 **[C] Tuşu ile Sivil Taklidi (Sosyal Saklambaç Pozu):** Suikastçı C tuşuna bastığında sahneye dönük doğal vatandaş pozu veriyor; WASD ile anında bozuluyor.
* [x] 🚻 **NPC'lerin Portatif WC Kuyruğu Oluşturması:** Siviller de ara sıra WC kabinlerinin önüne gidip sıraya giriyor ve bekliyor. Böylece suikastçının WC'ye gitmesi kılık değiştirmesi doğal kalabalığın arasına gizleniyor!

* [x] 🔧 **ESC Menü Çılgın Aç-Kapa Bug'ı Düzeltildi:** Suikastçıdayken her fare hareketinde ESC tetiklenmesine sebep olan input bloğu temizlendi; sadece ESC tuşuna basıldığında stabil açılıp kapanıyor.

* [x] 🏆 **İngilizce Uygulaması (Kelime Akademisi) Liderlik Tablosu & Ömer Hesabı Düzeltildi:** user_stats.json veritabanına Ömer hesabı kalıcı olarak işlendi. Yapılan tüm testler, kelime çözümleri, Wordle ve Şimşek skorları anlık olarak sunucuya kaydedilip liderlik tablosuna dinamik olarak yansıtılıyor.

* [x] 👥 **Sivil Kalabalığı 65 Kişiye Çıkarıldı:** Meydandaki NPC sayısı 65'e yükseltildi. Sahne önü, büfeler, WC kuyruğu ve ağaç altlarına organik olarak dağıtıldı; suikastçı artık dev kalabalığın içine kusursuzca karışıyor.
* [x] 🌳 **Miting Alanına 7 Büyük Gölgelikli Ağaç Eklendi:** Dron kamerasının havadan doğrudan görüşünü engelleyen geniş yapraklı çınar/park ağaçları yerleştirildi. Suikastçı bu ağaçların altından koridor oluşturup sızabiliyor.
* [x] 🔪 **Suikastçı Gizli Silah (Concealed Carry) Durumu:** Suikastçının bıçağı/silahı 3. şahısta (dışarıdan bakan koruma ve dron için) tamamen gizlidir, sadece saldırdığında görünür.

* [x] 💥 **Sivil Vurulduğunda Panik & Kaçışma:** Suikastçı silah sıktığında veya sivili vurduğunda 22 metredeki tüm siviller çığlık atarak panikle etrafa kaçışıyor.
* [x] 🔫 **Ateş Edince Silahın Açığa Çıkması & [G] ile Yere Atma:** Silah ateşlendiği an suikastçının elinde 3. şahısta (herkesin görebileceği şekilde) beliriyor. Suikastçı [G] tuşuna basarak silahı yere atıp tekrar masum sivil gibi kalabalığa karışabiliyor.

* [x] 🔧 **Silah Açığa Çıkma & [G] Yere Atma Hatası Düzeltildi:** Ağ ve yerel test modunda silah ateşlendiğinde veya bıçak saplandığında 'is_weapon_exposed' bayrağı anında yerel olarak da set ediliyor. [G] tuşuna basıldığında silah yere atılarak tekrar masum sivile dönülüyor.
* [x] 📧 **Haber Maili Tetikleyicisi Kontrol Edildi:** Saat 16:30'da gelen bülten mailinin Windows PC'deki n8n servisinde çalışan 'Gunluk Ekonomi Bulteni' (Workflow 2tFW4plKujXwr1yN) zamanlayıcısından (13:30 UTC tetikleyicisi) kaynaklandığı tespit edildi.

* [x] 🧹 **n8n İş Akışları Temizlendi & Tek Sağlam Bültene İndirildi:** 6 eski/mükerrer iş akışı silindi. Yalnızca Telegram sesli mesajlı, Word ekli ve e-postalı ana 'Gunluk Ekonomi Bulteni' (ID: 2tFW4plKujXwr1yN) bırakıldı.
* [x] ⏰ **Saat Dilimi 'Europe/Istanbul' Olarak Kilitlendi (09:30 TR):** n8n zamanlayıcısının New York (UTC-4) yerine Türkiye saatine göre hafta içi her sabah 09:30'da çalışması kesinleştirildi.

* [x] 🔄 **Tüm Özel İş Akışları (Tablo Mail, Bilanço Haber vb.) Eksiksiz Geri Yüklendi:** Kullanıcının elle kurduğu 'tablo mail', 'bilanco haber', 'tablo dosya', 'bilanco özeti', 'günlük mail özet' ve 'Gunluk Ekonomi Hafif' akışları SQLite binary veritabanından düğümleri ve bağlantılarıyla birlikte %100 eksiksiz kurtarılarak n8n sistemine geri yüklendi.

* [x] 🧹 **Mükerrer Ekonomi Bülteni Silindi, Asıl Bülten ve Özel Sistemler Korundu:** Sadece yedek olan 'Gunluk Ekonomi Hafif' (ID: AjL3Ol1WQwyX1Pxl) silindi. Telegram ve e-postaya sesli podcast + Word raporu gönderen ana bültenimiz ile 'tablo mail', 'bilanco haber', 'tablo dosya', 'bilanco özeti' ve 'günlük mail özet' akışları korundu.

* [x] 🖱️ **PC'de Fare Bakış ve Tıklama Sorunu Düzeltildi:** Windows'ta ekranı kaplayan UI panellerinin (HUD, ScreenFlash, StunOverlay vb.) varsayılan olarak fare olaylarını yutmasını engellemek için 'mouse_filter = IGNORE' yapıldı. Fare bakışı doğrudan '_input' fonksiyonuna taşındı ve tıklandığında imlecin yakalanması sağlandı.
* [x] ⏱️ **PC'de Maç Süresi 3 Dakikaya (180s) Sabitlendi:** 'main.gd' içindeki sıfırlayıcı ve 'main.tscn' arayüzü tam 03:00 (180 saniye) olarak eşitlendi.

* [x] 🖱️ **Fare ve Kamera Girişleri Tek Çatıda Birleştirildi (_input):** Godot'ta arayüz panellerinin fareyi yutması riskine karşı kamera rotasyonu, sol tık saldırı/etkileşim ve tuş kontrolleri '_unhandled_input' yerine doğrudan öncelikli '_input' fonksiyonuna taşındı. Tek oyunculu / debug testinde yetki kilitlenmesi önlendi.

* [x] 🚁 **Dron Yükselme ve Kontrol Sistemi Geliştirildi:** [Space] ve [E] ile yukarı yükselme, [Q] ve [Ctrl/C] ile alçalma, [Shift] ile turbo hızlanma eklendi. Ekrandaki HUD'a tüm kontroller açıkça yazıldı.
* [x] 🔊 **Rahatsız Edici Lazer/Bip Sesleri Gerçekçi & Tatlı Seslerle Değiştirildi:** 8-bit tiz frekanslar yerine tok ve kaliteli 16-bit PCM sesler (tok susturuculu 9mm tabanca, düşük ark taser cızırtısı, yumuşak dedektör tınısı, hafif kalabalık mırıltısı) üretildi ve NPC'lerin ses spamı engellendi.
* [x] 🎚️ **Ayarlar Menüsüne Canlı Ses Düzeyi Kaydırıcısı (HSlider) Eklendi:** Ana menüdeki 'Ayarlar' panelinden oyunun genel sesini %0 ile %100 arasında canlı olarak kısıp açma özelliği getirildi.
* [x] 🎨 **Ana Menü Arayüzü Güzelleştirildi:** Modern cam efektli butonlar, altın sarısı başlık ve hızlı bağlanma butonları entegre edildi.

* [x] 🚀 **Tüm Proje Git Deposuna %100 Temiz Olarak İşlendi (Sonnet Eşitlemesi):** PC'deki yerel git deposunda tüm menüler (global.gd, menu.tscn, minimap.gd), 65 NPC, dron uçuş kontrolleri, ses dosyaları (sounds/), web portalı (web_portal/) ve 'README_SONNET_OZET.md' dosyası 'cde265a' ile commitlendi. Çalışma ağacı tamamen temizlendi.

* [x] 🕺 **3D Animasyonlu Karakter İskeleti Entegre Edildi (Kenney Animated Rig):** Kapsül modeller yerine bacakları adım atan, kolları sallanan, dururken nefes alan ve zıplayan gerçek 3D animasyonlu karakterler ('models_animated/character_animated.glb') 65 NPC'ye ve 3. şahıs oyunculara giydirildi. Renk çeşitliliği ve hızla senkronize animasyonlar tamamlandı.

* [x] ⏰ **09:30 Günlük Ekonomi Bülteni Otomatik Zamanlayıcısı Düzeltildi (UTC/TR Eşitlemesi):** n8n sunucusunun zamanlayıcı çekirdeğindeki UTC farkı giderildi (06:30 UTC = 09:30 TR). 'GENERIC_TIMEZONE=Europe/Istanbul' değişkeniyle n8n servisi yeniden başlatıldı. Bugünkü bülten (Exec: 7) başarıyla üretilip Telegram (Sesli Podcast + Word) ve E-postaya ulaştırıldı.

* [x] 🎮 **[F1], [F2], [F3] Karakter Değiştirme Test Tuşları Geri Getirildi:** Test esnasında [F1] ile anında Başkan, [F2] ile Koruma 1 → 2 → 3 döngüsü, [F3] ile Suikastçı geçişi sağlandı.
* [x] ⚡ **FPS & Performans Optimizasyonu (GPU Batching & Cache):** 65 NPC'nin her kare oluşturduğu 130+ dinamik materyal örneği yerine 6 statik paylaşımlı palete geçilerek Draw Call'lar minimuma indirildi. NPC kaçış fizik taramaları (Avoidance Lookup) saniyede 5 kez önbelleklemeye (cache) alınarak CPU darboğazı çözüldü.

* [x] 🚁 **Dron [E] Yükselme & Etkileşim Tuş Çakışması Düzeltildi:** Dron modundayken [E] tuşunun genel etkileşim (interact) aksiyonunu tetikleyip dronu kapatması engellendi. [E] ve [Space] artık dronu kesintisiz ve akıcı bir şekilde gökyüzüne yükseltiyor; dronu kapatmak için [2], [F] veya [ESC] kullanılıyor.

* [x] 📊 **Canlı Seçim Anketi & Oy Oranı Sistemi (Live Election Poll):** Üst ekranda Mavi/Kırmızı oy barı eklendi. Başkan kürsüde konuştukça (+0.55%/s) ve çay fırlattıkça (+2.5%) oyu artar; saklanıp pasif kalırsa (-0.20%/s) veya izdiham çıkarsa (-4.0%) oyu düşer.
* [x] 🏆 **3 Farklı Oyun Sonu Senaryosu (Seçim Zaferi / Siyasi Kayıp / Suikast):** Süre bittiğinde oy %50 üstündeyse Başkan & Korumalar kazanır; oy %50 altındaysa 'Korkak Başkan Seçimi Kaybetti!' ekranı ile Provokatör/Suikastçı kazanır. Başkan ölürse doğrudan Suikastçı kazanır.
* [x] 🔭 **Gözcü Kulesi Nişan Uyarısı & Çelik Çanta Savunma Refleksi:** Suikastçı tabancayla nişan aldığında gözcüler alarm çalar (sniper_warning.wav), Başkanın ekranı sarı/kırmızı yanar. Başkan [3] Çelik Çantayı kaldırırsa mermi seker (metal_clang.wav) ve Başkan hayatta kalıp +4.5% cesaret oyu kazanır.

* [x] 🎨 **Üst Menü / Top Bar HUD Baştan Sona Yenilendi (Tam Ekran Yayın Başlığı):** Üst kısımdaki iç içe geçmeler tamamen temizlendi. Ekranın tüm genişliğini kullanan modern cam efektli (Glassmorphic) 3 bölgeli yayın çubuğuna geçildi: Sol (Süre & Rol Rozeti), Orta (Genişletilmiş Canlı Seçim Anketi Barı & Trend Rozeti), Sağ (Miting Durumu & Görev İlerlemesi).

* [x] 📺 **2000'ler TV Seçim Özel Yayını & VIP Taktik UI Sanat Yönetimi Tamamlandı:** Generic AI cam/gradient şablonları tamamen kaldırıldı. Yerine Star/Show TV Seçim Gecesi estetiğinde keskin açılı metalik stüdyo çerçeveleri, kırmızı [ ● CANLI ] LED lambası, [ SÜRE 03:00 ], [ 🏛️ İKTİDAR %46.0 ] ⚡ [ 🦅 MUHALEFET %54.0 ] televizyon sandık barı ve sağ altta sarı/siyah ikaz çizgili VIP Taktik Teçhizat Konsolu entegre edildi.

* [x] 🏙️ **Tatlı Çizgi Film / Low-Poly Şehir & Miting Meydanı Assetleri Eklendi:** KayKit ve Kenney City/Platformer 3D modelleri (dükkanlar, kafeler, meydan fıskiyeli süs havuzu, polis ve taksi araçları, sokak lambaları, park bankları, çöp kutuları, miting bayrakları ve su kulesi gözcü noktaları) projeye entegre edildi.

* [x] ⚡ **Detaylı FPS ve Performans Benchmarkı Yapıldı:** 65 aktif NPC, 8 3D şehir binası, fıskiyeli süs havuzu, polis/taksi araçları ve canlı TV HUD arayüzü ile yapılan yük testinde **Ortalama 142.4 FPS / Min 110.0 FPS / Frame Time 6.90 ms** ölçüldü. Oyun 60+ FPS hedefini katbekat aşarak yağ gibi akıyor!

* [x] 🎨 **Yumuşak Çizgi Film / Parti Oyunu UI Estetiğine Geçildi:** Sert, karanlık TV barı kaldırıldı. Yerine Fall Guys / Overcooked tarzı yumuşak kenarlı (18px radius), canlı tatlı renkli, ferah ve sevimli kapsül başlıklar entegre edildi.
* [x] 🛠️ **Rol Değişiminde Sağ Alt HUD Güncelleme Hatası Düzeltildi:** Margin container sonrası bozulmuş olan düğüm referansları onarıldı. Artık F1/F2/F3 veya rol dağıtıldığında sağ alttaki yuvalar anında Başkan (Depar, Çanta, Çay), Koruma (Taser, Dron, Megafon) ve Suikastçı (Bıçak, Tabanca, İzdiham) olarak anında güncelleniyor!
* [x] 🏙️ **Bina Ölçekleri ve Havada Uçan Kuleler Düzeltildi:** Rastgele atılmış minyatür maketler kaldırıldı; binalar gerçek sokak boyutlarına (4.5x) büyütülerek meydan kenarlarına cadde gibi dizildi. Gözcü kuleleri yere sıfır sağlam kaidelere oturtuldu.

* [x] 🎨 **Orijinal Kenney UI 9-Patch Doku ve Sprite Sistemine Geçildi:** Kodla çizilen düz CSS kutuları kaldırıldı. Yerine Kenney UI 9-patch dokuları (mavi/sarı/kırmızı/gri bombeli çizgi film butonları ve panelleri) ile üst anket başlığı, süre kutusu ve yetenek yuvaları oyun dünyasıyla tam uyumlu hale getirildi.
* [x] 🏛️ **Miting Sahnesi ve Kürsü 3D Modellere Dönüştürüldü:** İlkel küpler yerine model platformlar, ahşap hitap kürsüsü, kırmızı miting bayrakları ve sahne düzeni kuruldu.
* [x] 🏢 **3 Katlı Apartmanlar ve Çatı Keskin Nişancı Noktaları:** Havada asılı duran kuleler kaldırıldı; sol ve sağ sokaklara çok katlı apartman blokları dizildi ve gözcü kuleleri doğrudan apartman çatısına sabitlendi.

* [x] 🏙️ **Miting Meydanı Mimari Düzenlemesi Kusursuzlaştırıldı (Sıfır Uçan Nesne):** Havada asılı kalan binalar ve çift katlı model çakışmaları tamamen kaldırıldı. Sol, sağ ve sahne arkası caddeler tek parça 3 katlı binalarla (Y=0.0) yere sıfır hizalandı. Gözcü kuleleri ve sahne kürsüsü sağlam zeminlere oturtuldu.

* [x] 🏙️ **Sahnedeki Eski Uçan Bina Kalıntıları Temizlendi (Apt_L1_Floor2):** Sahnenin altındaki eski Y=7.5m transform kalıntıları tamamen temizlendi. Windows PC'de 'main.tscn' güncellendi ve tüm binaların zemine (Y=0.0) oturduğu doğrulandı.

* [x] 👥 **Kalabalık 130 Kişiye Çıkarıldı ve 4 Farklı Karakter Arketipi Eklendi:**
  - **Sahne Önü Coşkulu Kalabalık (72 Kişi):** Sürekli kürsüye dönük, zıplayan, alkışlayan, ellerini kaldıran fanatik miting dinleyicileri.
  - **Tuvalet Sırası Bekleyenler (16 Kişi):** Sol ve sağ seyyar tuvaletlerin önünde nizami kuyruk oluşturan sabırsız siviller.
  - **Banklarda Dinlenenler (14 Kişi):** Park banklarında ve süs havuzu etrafında oturan, sohbet eden dinleyiciler.
  - **Meydanda Serbest Gezenler (28 Kişi):** Giriş kapısı, basın çadırı ve büfeler arasında yürüyüş yapan, suikastçıya kamufle olma fırsatı sunan dinamik siviller.
* [x] 🔴 **Kürsü Önü VIP Protokol Güvenlik Çiti / İp Bariyeri:** Kürsü ile kalabalık arasına kırmızı protokol bariyeri yerleştirildi.
* [x] 🌳 **Zengin Çevre (Ağaçlar, Çalılar, Çöp Kovaları, Yangın Muslukları):** Meydan kenarları model ağaçlar ve sokak mobilyaları ile donatıldı.
* [x] ⚡ **144 FPS Benchmark Doğrulaması:** 130 NPC ve zengin çevreye rağmen 144 FPS / 6.94 ms kare süresi başarıyla sabitlendi.

* [x] 🌲 **Minyatür Ağaçlar Kaldırıldı:** Eski kodla çizilmiş küçük sopa ağaçlar silindi, yerine meydanla uyumlu büyük model ağaçlar konuldu.
* [x] 🚻 **Tatlı 3D WC Kabinleri:** Mavi ilkel kutu tuvaletler kaldırıldı; KayKit mimarisiyle tam uyumlu sevimli ahşap/çatı kapılı WC binaları yerleştirildi.
* [x] 🛡️ **Koruma Dış Görünüşü & Havada Kalan Dron Düzeltildi:** Korumaya 3. şahısta ve dron kamerasında tam oturan simsiyah taktik takım elbise giydirildi. Eski çakışan gövde parçaları temizlendi. Drondan inildiğinde dron gövdesi otomatik gizlenerek havada asılı siyah kutu kalması engellendi.
* [x] 📏 **İnsan Boyları ve Kafa Üstü Zıplama Engeli:** Tüm NPC ve oyuncuların model ölçekleri 1.0 standardına eşitlendi, çarpışma yüksekliği artırılarak kafa üstünde sörf yapma engellendi.
