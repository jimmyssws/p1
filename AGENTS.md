# 🎮 GODOT 3D OYUN PROJESİ - MASTER MEMORY

## 📌 Proje Genel Bakışı
Bu klasör, Godot oyun motoru ile geliştirilen 3D ana oyun projesinin tek ve güncel kaynak kodudur.

## 🛡️ KRİTİK KURALLAR & GÜVENLİK (KODU ESKİYE DÖNDÜRMEME)
1. **ASLA ESKİ SÜRÜME DÖNDÜRME:** `scenes/`, `scripts/` ve `models_animated/` dizinlerindeki mevcut çalışan düğüm (node) yapılarını, karakter animasyonlarını (`walk.fbx`, `idle.fbx`) veya ses üreticilerini (`gen_sounds.py`, `create_warning_sound.py`) bozma.
2. **Godot Ayarları:** `project.godot` yapılandırmasını değiştirmeden önce mutlaka yedek kontrolü yap.

## 📚 Proje Notları & GDD Dokümanları
Bu projenin tüm GDD, kriz mekaniği, ses ve harita tasarım dokümanları `./notes/` klasöründedir:
- `notes/02_🎯_GDD_Oyun_Tasarim_Dokumani.md`: Oyun Tasarım Dokümanı
- `notes/03_🗺️_Harita_ve_Cevre_Tasarimi.md`: Harita ve çevre mimarisi
- `notes/04_🧠_Yapay_Zeka_ve_Sivil_Davranislari.md`: Sivil AI yapısı
- `notes/Miting_Oyunu_Kriz_Mekanigi.md`: Kriz ve karar mekanikleri


## 🧠 PROJECT_MEMORY.MD GÜNCELLEME KURALI (MANDATORY)
Projede yapılan HER yeni geliştirme, mimari değişiklik, hata düzeltmesi veya eklenen özellik; TAMAMLANDIKTAN ANINDA SONRA projenin kökündeki  dosyasına tarih atılarak 1-2 cümlelik özet halinde eklenmelidir.
