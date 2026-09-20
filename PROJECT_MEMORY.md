# 🧠 GODOT - PROJECT MEMORY & PROJE HAFIZASI

## [2026-09-02] - Proje Hafızası Başlatıldı
- Proje mimarisi ve koruma kuralları aktif edildi.

## [2026-09-21] - Ana Menü Radyo Teması ile Tamamen Yenilendi
- **`menu_backdrop.gd`** → Tam ekran retro FM radyo kasası olarak yeniden yazıldı. Animasyonlu VU-meter (8 kanal), frekans şeridi (88-108 MHz), hoparlör ızgaraları (sol/sağ), LED göstergeler (STEREO / LIVE / REC), sinyal gücü çubukları, krom çerçeveler — hepsi procedural olarak `_draw()` ile çiziliyor, asset kullanılmıyor.
- **`radio_tuner.gd`** → Küçük köşe widget'ından merkez panelin tepesine tam genişlikte frekans şeridine dönüştürüldü. Hover'da `tune(freq, title, subtitle)` çağrısı ile aktif kanal canlı güncelleniyor.
- **`menu_visuals.gd`** → Tamamen yeniden yazıldı. CenterBox artık hoparlörler arasındaki radyo merkez paneline (anchor %27-%73 yatay, %5.5-%94.5 dikey) hizalandır. Butonlar radyo tuş takımı estetiğine kavuştu.
- **Değişmeyen yapılar:** `menu.gd` (tüm sinyal bağlantıları, ağ kodu, ayar kaydetme), `menu.tscn` (node hiyerarşisi), diğer scene ve script dosyaları dokunulmadı.

## [2026-09-21] - Menü Gerçek Atmosferik Görselle Yenilendi
- **`assets/menu_bg.jpg`** → AI ile üretilmiş sinematik gece miting sahnesi arka planı eklendi (kalabalık, arama ışıkları, kızıl bayraklar, sahne).
- **`assets/menu_btn.jpg`** → Karanlık metal buton texture'ı eklendi (sol altın çizgi accent, çizik metal doku).
- **`menu_backdrop.gd`** → Procedural radyo kasası yerine gerçek `menu_bg.jpg` kullanıyor; üstüne %58 siyah overlay + CRT tarama çizgileri + animasyonlu VU-meter şeridi eklendi.
- **`menu_visuals.gd`** → Sinematik thriller stili uygulandı; butonlar minimal sol-kenar accent çizgisi ile yeniden stilize edildi, procedural radyo kasası kaldırıldı.i altın kenarlıklı retro stile getirildi.
- **Değişmeyen yapılar:** `menu.gd` (tüm sinyal bağlantıları, ağ kodu, ayar kaydetme), `menu.tscn` (node hiyerarşisi), diğer scene ve script dosyaları dokunulmadı.

## [2026-09-21] - Silah, Taser ve Bıçak Sesleri Ayrıştırıldı & Güçlendirildi
- `gunshot.wav` (tok barut patlaması & sub-bass yankı), `taser.wav` (50.000V yüksek voltaj elektrik arkı & gaz kapsülü) ve `knife.wav` (keskin çelik kavis savurması) sesleri tamamen farklı ve belirgin katmanlarla yeniden sentezlendi.
- `player.gd` üzerinde lokal 2D stereo net ses oynatma ve role özel silah çekme foley sesleri aktif edildi.
