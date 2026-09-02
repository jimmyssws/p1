# Miting Oyunu – Kriz Mekanigi

## 1. Araştırma Özeti

Siyasi strateji ve simülasyon oyunlarında (ör. **Democracy 4**, **Political Animals**, **Tropico** ve **Civilization VI**) rastgele kriz/olay yönetimi genellikle aşağıdaki prensiplere dayanır:

| Kaynak | Kullanılan Mekanizma | Örnek
|--------|----------------------|------|
| **Event Table** | Olaylar bir tabloya konur, her olayun bir **weight** (olasılık) ve **trigger condition** (koşul) vardır. | Democracy 4 – “Scandal”, “Economic Crash”
| **Weighted Random Selection** | Olay seçimi, ağırlıklı rastgelelik (roulette wheel) ile yapılır; koşul sağlanıyorsa seçim havuzuna eklenir. | Political Animals – “Media Leak”
| **Decision Tree / Choice System** | Olay tetiklendiğinde oyuncuya bir veya birden fazla **choice** sunulur; her seçimin **impact** (popülerlik, bütçe, itibar) ve **next‑event** bağlantısı vardır. | Tropico 6 – “Storm” sonrası “Rebuild” seçeneği
| **Dynamic Modifiers** | Olayların etkileri, mevcut **polling**, **budget**, **public opinion** gibi değişkenlere göre ölçeklenir. | Civilization VI – “War Weariness”
| **Cooldown / Cooldown Groups** | Aynı tipteki olayların çok sık tetiklenmesini önlemek için **cooldown timers** veya **group tags** kullanılır. | Democracy 4 – “Scandal” cooldown 30‑day

Bu mekanizmalar, **süreklilik**, **oyuncu seçimi** ve **dengeli zorluk** sağlamak için bir arada çalışır.

---

## 2. EventManager.gd – Mimari Tasarım

### 2.1. Genel Bakış

`EventManager.gd` oyunun **global singleton** (AutoLoad) olarak çalışır ve aşağıdaki sorumlulukları üstlenir:

1. **Event Tanımları** – JSON‑benzeri sözlüklerde olayların meta verileri (isim, açıklama, weight, trigger, choices, cooldown). 
2. **Koşul Kontrolü** – Oyun durumuna (anket, bütçe, skandal seviyesi, vb.) göre hangi olayların aktif olabileceğini belirler.
3. **Ağırlıklı Rastgele Seçim** – Aktif olay havuzundan bir olay seçer.
4. **Karar Ağacı** – Seçilen olayın **choices** listesini oyuncuya sunar ve seçilen seçeneğin etkilerini uygular.
5. **Cooldown Yönetimi** – Olayların tekrar tetiklenme süresini izler.
6. **Signal/Callback** – Diğer sistemlere (CrowdManager, UI, Audio) olay gerçekleştiğinde sinyal gönderir.

### 2.2. Sınıf Diyagramı (GDScript)

```
EventManager (Node)
├─ const EVENT_DEFINITIONS : Array[Dictionary]
├─ var active_events : Array[Dictionary]
├─ var cooldowns : Dictionary   # {event_id: remaining_seconds}
├─ signal event_started(event_id)
├─ signal event_resolved(event_id, choice_id)
│
├─ _ready()                     # AutoLoad init
├─ _process(delta)              # cooldown tick
├─ func evaluate_triggers() -> void
├─ func select_random_event() -> Dictionary
├─ func trigger_event(event:Dictionary) -> void
├─ func apply_choice(event_id:String, choice_id:int) -> void
└─ func get_event_by_id(id:String) -> Dictionary
```

### 2.3. Örnek Event Tanımı

```gdscript
# EventManager.gd içinde kullanılacak örnek bir event tanımı
var EVENT_DEFINITIONS = [
    {
        "id": "scandal_leak",
        "name": "Skandal Sızıntısı",
        "description": "Bir gazeteci, partinin içindeki bir skandalı ortaya çıkarıyor.",
        "weight": 30,
        "trigger": {
            "min_poll": 40,   # anket %40'ın altında ise daha yüksek olasılık
            "max_scandal": 2   # mevcut skandal seviyesi 2'den düşük olmalı
        },
        "cooldown": 86400,   # 24 saat
        "choices": [
            {
                "id": 0,
                "text": "Açıkça reddet",
                "impact": {"poll": -5, "scandal": +1},
                "next_event": null
            },
            {
                "id": 1,
                "text": "Özür dile ve reform vaat et",
                "impact": {"poll": +3, "scandal": -1},
                "next_event": "reform_success"
            }
        ]
    },
    {
        "id": "poll_swing",
        "name": "Anket Dalgalanması",
        "description": "Bir kamuoyu araştırması, partinin popülaritesinde ani bir artış/azalış gösteriyor.",
        "weight": 20,
        "trigger": {"time_since_last_poll": 3},
        "cooldown": 43200,
        "choices": [
            {"id":0,"text":"Mesajını güçlendir","impact":{"poll":+2},"next_event":null},
            {"id":1,"text":"Rakibi suçla","impact":{"poll":+1,"scandal":+1},"next_event":null}
        ]
    }
]
```

### 2.4. Önemli Fonksiyonlar

```gdscript
func evaluate_triggers() -> void:
    active_events.clear()
    for ev in EVENT_DEFINITIONS:
        if _check_trigger(ev) and not _is_on_cooldown(ev.id):
            active_events.append(ev)

func _check_trigger(ev:Dictionary) -> bool:
    var t = ev.trigger
    # Örnek koşullar – oyun durumundan alınan değerler GlobalState üzerinden çekilir
    if t.has("min_poll") and GlobalState.poll < t.min_poll:
        return true
    if t.has("max_scandal") and GlobalState.scandal_level > t.max_scandal:
        return false
    if t.has("time_since_last_poll") and GlobalState.days_since_last_poll < t.time_since_last_poll:
        return false
    return true

func select_random_event() -> Dictionary:
    if active_events.empty():
        return {}
    var total_weight = 0
    for ev in active_events:
        total_weight += ev.weight
    var roll = randi() % total_weight
    var cumulative = 0
    for ev in active_events:
        cumulative += ev.weight
        if roll < cumulative:
            return ev
    return {}

func trigger_event(event:Dictionary) -> void:
    emit_signal("event_started", event.id)
    # UI'ye gönder – EventUI.show(event)
    # Cooldown başlat
    cooldowns[event.id] = event.cooldown

func apply_choice(event_id:String, choice_id:int) -> void:
    var ev = get_event_by_id(event_id)
    var choice = ev.choices[choice_id]
    # GlobalState üzerindeki etkileri uygula
    for key in choice.impact.keys():
        GlobalState[key] += choice.impact[key]
    emit_signal("event_resolved", event_id, choice_id)
    # Sonraki event varsa tetikle
    if choice.next_event:
        var next_ev = get_event_by_id(choice.next_event)
        trigger_event(next_ev)
```

### 2.5. Entegrasyon Noktaları

| Sistem | Bağlantı Noktası |
|--------|------------------|
| **CrowdManager** | `event_started` sinyaliyle kalabalık moralini artır/azalt.
| **PoliticianSpeech** | Olay sonrası konuşma metni `EventUI.get_speech(event_id)` ile alınır.
| **UI** | `EventUI.show(event)` – olay penceresi, seçim seçenekleri.
| **Audio** | `AudioManager.play("crisis_alert")` – kritik olaylarda ses.

---

## 3. Kullanım Talimatları

1. **AutoLoad** → `EventManager.gd` dosyasını **Project Settings → AutoLoad** kısmına ekleyin (`EventManager`).
2. **GlobalState** → Oyun içi anket, skandal, bütçe gibi değişkenleri tutan bir singleton (`GlobalState.gd`).
3. **Her Güncellemede** → `EventManager.evaluate_triggers()` ve `EventManager.select_random_event()` çağrıları, ör. `DayCycle.gd` içinde bir gün sonunda çalıştırılır.
4. **UI** → `EventUI.gd` scripti, `event_started` sinyalini dinleyerek olay penceresini gösterir, oyuncu seçimini `apply_choice()` ile gönderir.
5. **Cooldown** → `_process(delta)` içinde `cooldowns` sözlüğü azaltılır; süresi 0 olduğunda ilgili event tekrar havuza eklenir.

---

## 4. İleri Geliştirme Önerileri

| # | Öneri |
|---|-------|
| 1 | **Modüler Event Pack** – JSON dosyalarıyla dışarıdan yeni olaylar eklenebilir.
| 2 | **AI‑Driven Event Generation** – Makine öğrenmesiyle oyuncu davranışına göre dinamik olay ağırlıkları.
| 3 | **Narrative Branching** – Bir olayın sonucu, sonraki haftaların olay tablosunu etkileyen **story flags** ekleyin.
| 4 | **Multiplayer Sync** – Çoklu oyuncu modunda olayların deterministic olması için seed‑based random.
| 5 | **Analytics** – Olayların oyuncu memnuniyeti üzerindeki etkisini ölçmek için telemetry.

---

*Bu doküman, Miting Oyunu’nun kriz yönetimi sistemini hızlıca prototiplemek ve genişletmek için temel bir çerçeve sunar.*
