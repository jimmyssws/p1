# 🎯 OYUN TASARIM DOKÜMANI (GDD): "MİTİNG ALANI: SUİKASTÇI & KORUMALAR"

**Tür:** 3D Çok Oyunculu Sosyal Çıkarım / Gizlilik & Koruma (SpyParty + Among Us + Town of Salem)
**Motor:** Godot 4.7 (GDScript)
**Sürüm:** v0.05 Alpha
**Harita:** 100x110m "Büyük Miting Meydanı" (Özgürlük Meydanı)

---

## 🎭 1. Roller ve Ekipman Tasarımları

### 🏛️ BAŞKAN (The President)
* **Amaç:** Suikastçıya hedef olmadan 3 aşamalı miting görevini tamamlamak.
* **Ekipman & Yetenekler:**
  - `[1] 🏃 Adrenalin Deparı:` 3 saniyeliğine %80 hız artışı.
  - `[2] 📢 Miting Megafonu:` *"Sevgili Vatandaşlarım!"* diyerek kalabalığı sahne önüne toplar.
  - `[3] 💼 Çelik Çanta Kalkanı:` 1 ölümcül bıçak/kurşun darbesini tamamen bloklar.
  - `[4] 🕺 Seçim Şarkısı:` Meydandaki tüm kalabalığı coşturup dans ettirir.
* **3 Aşamalı Görev Zinciri:**
  1. 🎙️ **Kürsü Konuşması (Sahne Ortası):** [E] ile 13 sn konuşma yapılır, haber bandında vaatler akar.
  2. 🤝 **Halkla Selamlaşma (Protokol Bariyeri):** [E] ile 10 sn halk selamlanır.
  3. 🎥 **Canlı Basın Röportajı (Basın Çadırı):** [E] ile 10 sn demeç verilir. *(Tamamlanınca Başkan kazanır!)*

---

### 🛡️ KORUMA TİMİ (The Bodyguards - 3 Kişilik Özel Tim)
* **Ortak Standart Silah:** `[1] ⚡ Taser (7.5m Menzil, 4.5s Bayıltma)`
* **Koruma Sınıfları (Slot 2):**
  1. **🛡️ Koruma 1 (İstihbarat / Dedektör Uzmanı):** `[2] 📡 Metal Dedektörü` (Absürt eşya ve gizli silah taraması).
  2. **🛡️ Koruma 2 (Hava Desteği / Dron Operatörü):** `[2] 🚁 Gözetleme Dronu` (Gökyüzünden mitingi kuşbakışı izleme).
  3. **🛡️ Koruma 3 (Güvenlik Anonsçusu):** `[2] 📢 'Herkes Dursun!' Megafonu` (Tüm sivilleri durdurup şüpheliyi açık eder).
* **🔍 [E] ile Üst Arama:** Bayılan şahsın yanına gidip 1.0 saniye içinde [E] basılı tutulur. Suikastçıysa silahlar çıkar ve zafer gelir; masumsa sandviç çıkar ve koruma ceza alır!

---

### 🗡️ SUİKASTÇI (The Assassin)
* **Amaç:** Sivillerin arasına karışıp korumalara çaktırmadan Başkanı ortadan kaldırmak.
* **Silah ve Taktikleri:**
  - `[1] 🔪 Susturuculu Bıçak:` 3.2m menzilli sessiz tek vuruş.
  - `[2] 🔫 Tek Mermili Tabanca:` 18m menzilli yüksek sesli tabanca.
  - `[3] 📢 İzdiham Çıkar (Stampede):` Turnikelerden içeri 15 sivili hücum ettirip kargaşada sızma.
* **Kaçış Fırsatı:** Şok yediğinde korumalar 4.5 saniye içinde aramazsa ayağa fırlar ve deparla kalabalığa karışır!
