# 🧠 YAPAY ZEKA VE SİVİL KALABALIK SİSTEMİ

## 👥 1. Sivil Kalabalık Mantığı
* **Durum Makinesi (FSM):** `WATCH_STAGE`, `WANDER`, `CHAT`, `CHEER`, `PANIC`.
* **3D Konumsal Ses:** Kalabalığın içine girince The Sims tarzı fısıltılar ve gevezelikler duyulur; uzaklaşınca sessizleşir.

## 🛡️ 2. Korumadan Kaçış & Yol Verme (Guard Avoidance Steering)
* Koruma 5.2 metre yaklaştığında siviller doğal bir şekilde kenara çekilip koruma için temiz bir yürüyüş koridoru açar.
* Koruma depar atarsa panikle geriye doğru kaçışırlar.

## 📢 3. 'Herkes Dursun!' Megafon Reaksiyonu
* Koruma 3 megafondan anons geçtiğinde:
  - **%80 Sivil:** 0.3 ile 2.2 saniye içinde durup ellerini yana açar ve etrafına bakınır.
  - **%20 Huysuz Sivil:** Durmayıp söylenerek yürümeye devam eder.
