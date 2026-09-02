# Miting Oyunu Geliştirme Raporu

## 1. Godot 4 için Optimize 3D Kalabalık (Crowd/NPC) Simülasyonu ve Performans Teknikleri

Araştırma sonucunda **Godot 4**'te büyük ölçekli 3D kalabalıklar oluştururken performansı maksimize eden aşağıdaki teknikler öne çıktı:

| # | Teknik | Açıklama | Kullanım Önerisi |
|---|--------|----------|------------------|
| 1 | **MultiMeshInstance3D** | Tek bir draw call ile binlerce aynı mesh'i render eder. Transform, renk ve custom data gibi özellikler GPU’da güncellenebilir. | NPC modelleri aynı mesh (ör. insan silueti) kullanıyorsa MultiMesh ile konum ve animasyon verileri shader üzerinden beslenir. |
| 2 | **GPU‑Based Animation (Shader Animation)** | Geleneksel Skeleton/AnimationPlayer yerine vertex shader’da basit yürüyüş/idle animasyonları yapılır. | Çok sayıda basit NPC için düşük‑poly mesh ve shader animasyonu tercih edin. |
| 3 | **NavigationServer & NavigationAgent3D** | Godot 4’ün yeni navigation sistemi, **crowd avoidance** ve **pathfinding** için native C++ implementasyonu sunar. | NPC’ler NavigationAgent3D üzerinden yönlendirilirken `avoidance_enabled` ve `max_speed` gibi parametreler ince ayar yapılmalı. |
| 4 | **Level‑of‑Detail (LOD) ve Culling** | Uzaktaki NPC’ler düşük poly LOD mesh’e geçer, görünürlük dışında olanlar tamamen cull edilir. | `VisibilityNotifier3D` ve `LOD` scripti ile mesafeye göre mesh değişimi sağlanabilir. |
| 5 | **Physics Layers & Collision Masks** | Çarpışma kontrolleri sadece gerekli katmanlarda yapılır, gereksiz fizik hesaplarından kaçınılır. | NPC’ler sadece yürüyüş ve yol bulma için collision shape kullanır; etkileşim dışı nesnelerle çarpışma devre dışı bırakılır. |
| 6 | **Multithreaded Processing** | Geniş NPC veri güncellemeleri (ör. davranış ağacı, kalabalık yönlendirme) ayrı thread’lerde çalıştırılır. | `Thread` sınıfı veya `WorkerThreadPool` ile toplu konum/animasyon güncellemeleri paralel yapılabilir. |
| 7 | **Instancing with PackedScene** | Tek tek sahne instance’ları yerine **PackedScene** üzerinden hızlı spawn ve reuse (object pool) yapılır. | NPC’ler ölü olduğunda sahne pool’dan geri alınır, yeni spawn’da yeniden kullanılabilir. |
| 8 | **Custom GDScript vs C# vs C++ Modules** | Performans kritik kodlar C++ GDNative veya C# ile yazılmalı. | Pathfinding ve avoidance gibi sık kullanılan algoritmalar C++ modülü olarak paketlenebilir. |
| 9 | **Signal‑Based Updates** | Her frame `process()` yerine sadece değişiklik olduğunda sinyal gönderilir. | NPC davranış değiştiğinde `emit_signal` ile ilgili sistemler tetiklenir, gereksiz per‑frame iş yükü azalır. |
|10| **Memory Management & Object Pooling** | Yeni nesne oluşturma/ yok etme maliyetini azaltmak için önceden tahsis edilmiş havuzlar kullanılır. | `ObjectPool` sınıfı ile NPC node’ları yeniden kullanılabilir. |

## 2. Script Mimarisi Tasarımı

### 2.1 `CrowdManager.gd`

```gdscript
# CrowdManager.gd
extends Node3D

class_name CrowdManager

# === CONFIGURABLE PARAMETERS ===
export var npc_scene: PackedScene                     # PackedScene of the NPC (PoliticianSpeech.gd attached)
export var max_npc_count: int = 5000                 # Simultaneous NPC limit
export var spawn_radius: float = 30.0                # Radius around manager where NPC spawn edilir
export var lod_distances: Array[float] = [15, 30, 60] # LOD seviyeleri (near, mid, far)

# === INTERNAL NODES ===
onready var multimesh_instance: MultiMeshInstance3D = MultiMeshInstance3D.new()
onready var navigation: NavigationRegion3D = NavigationRegion3D.new()

# === POOLING ===
var npc_pool: Array[Node] = []
var active_npcs: Array[Node] = []

# === SIGNALS ===
signal npc_spawned(npc: Node)
signal npc_removed(npc: Node)

func _ready() -> void:
    # MultiMesh setup
    var multimesh = MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.color_format = MultiMesh.COLOR_FLOAT
    multimesh.custom_data_format = MultiMesh.CUSTOM_DATA_FLOAT
    multimesh.instance_count = max_npc_count
    multimesh_instance.multimesh = multimesh
    add_child(multimesh_instance)
    
    # Navigation region (optional, can be loaded from a pre‑baked navigation mesh)
    add_child(navigation)
    
    # Pre‑allocate pool
    for i in max_npc_count:
        var npc = npc_scene.instantiate()
        npc.visible = false
        npc_pool.append(npc)
        add_child(npc) # keep in scene tree for easy access
    
    # Start spawning coroutine
    spawn_initial_npcs()

func spawn_initial_npcs() -> void:
    for i in min(200, max_npc_count):
        spawn_npc()

func spawn_npc() -> void:
    if npc_pool.is_empty():
        return
    var npc = npc_pool.pop_back()
    var pos = global_transform.origin + Vector3(randf()*2-1, 0, randf()*2-1).normalized()*randf()*spawn_radius
    npc.global_transform.origin = pos
    npc.visible = true
    active_npcs.append(npc)
    emit_signal("npc_spawned", npc)
    # Register with navigation agent if needed
    if npc.has_method("setup_navigation"):
        npc.setup_navigation(navigation)

func despawn_npc(npc: Node) -> void:
    if active_npcs.erase(npc):
        npc.visible = false
        npc_pool.append(npc)
        emit_signal("npc_removed", npc)

# === FRAME UPDATE ===
func _process(delta: float) -> void:
    update_multimesh()
    update_lod()
    # Optional: periodic spawn/despawn based on player proximity

func update_multimesh() -> void:
    var mm = multimesh_instance.multimesh
    for i in active_npcs.size():
        var npc = active_npcs[i]
        mm.set_instance_transform(i, npc.global_transform)
        # custom data can hold animation blend factor, crowd‑state etc.
        var blend = npc.get("animation_blend") if npc.has_method("get") else 0.0
        mm.set_instance_custom_data(i, Color(blend, 0, 0, 1))

func update_lod() -> void:
    var cam = get_viewport().get_camera_3d()
    if not cam:
        return
    for npc in active_npcs:
        var dist = cam.global_transform.origin.distance_to(npc.global_transform.origin)
        var lod_index = 0
        for d in lod_distances:
            if dist > d:
                lod_index += 1
        npc.call_deferred("set_lod", lod_index)
```

### 2.2 `PoliticianSpeech.gd`

```gdscript
# PoliticianSpeech.gd
extends CharacterBody3D

class_name PoliticianSpeech

# === PUBLIC PROPERTIES ===
export var walk_speed: float = 3.0
export var run_speed: float = 6.0
export var speech_clips: Array[AudioStream] = []

# === INTERNAL STATE ===
var navigation_agent: NavigationAgent3D
var current_target: Vector3
var animation_blend: float = 0.0   # MultiMesh custom data için
var lod_level: int = 0            # 0 = high, 1 = medium, 2 = low

# === SIGNALS ===
signal reached_target()

func _ready() -> void:
    navigation_agent = NavigationAgent3D.new()
    add_child(navigation_agent)
    navigation_agent.max_speed = walk_speed
    navigation_agent.target_reached.connect(_on_target_reached)
    # Random initial destination inside manager radius
    set_random_destination()

func set_random_destination() -> void:
    var manager = get_parent() as CrowdManager
    if not manager:
        return
    var angle = randf() * TAU
    var radius = randf() * manager.spawn_radius
    current_target = manager.global_transform.origin + Vector3(cos(angle), 0, sin(angle)) * radius
    navigation_agent.set_target_position(current_target)

func _physics_process(delta: float) -> void:
    if navigation_agent.is_navigation_finished():
        return
    var next = navigation_agent.get_next_path_position()
    var direction = (next - global_transform.origin).normalized()
    velocity = direction * navigation_agent.max_speed
    move_and_slide()
    # Simple blend for shader (0 = idle, 1 = walking)
    animation_blend = lerp(animation_blend, 1.0, 0.1)

func _on_target_reached() -> void:
    animation_blend = 0.0
    emit_signal("reached_target")
    # Play a random speech after a short pause
    if not speech_clips.is_empty():
        var audio = AudioStreamPlayer3D.new()
        add_child(audio)
        audio.stream = speech_clips[randi() % speech_clips.size()]
        audio.play()
    # Choose next point
    set_random_destination()

# === LOD HANDLING ===
func set_lod(level: int) -> void:
    lod_level = level
    match lod_level:
        0:
            # high‑poly mesh, full animation
            $MeshInstance3D.visible = true
            $LowPolyMesh.visible = false
        1:
            # medium LOD – simplified material, no bone animation
            $MeshInstance3D.visible = false
            $LowPolyMesh.visible = true
            $LowPolyMesh.material_override = preload("res://materials/npc_mid_lod.tres")
        2:
            # low LOD – only billboard sprite or point cloud
            $LowPolyMesh.visible = false
            $Billboard.visible = true

# === NAVIGATION SETUP FROM CrowdManager ===
func setup_navigation(nav_region: NavigationRegion3D) -> void:
    navigation_agent.navigation_map = nav_region.get_navigation_map()
```

## 3. Kritik Teknik Görevleri (TASKS.md’ye eklenecek)

1. **MultiMesh Shader Optimisation** – NPC’lerin yürüyüş animasyonlarını GPU‑shader ile gerçekleştirecek bir `crowd_shader.gdshader` dosyası oluştur ve performans profili al.
2. **Navigation Mesh Generation** – Harita için yüksek çözünürlüklü bir NavigationMesh oluştur, `NavigationRegion3D` içine embed et ve `CrowdManager` ile entegre et.
3. **LOD System Implementation** – `CrowdManager` içinde mesafeye dayalı LOD geçişlerini yönetecek `LODManager.gd` scriptini geliştir.
4. **Object Pool & Threaded Update** – NPC nesne havuzunu (`ObjectPool`) ve `WorkerThreadPool` kullanarak konum‑animasyon güncellemelerini paralel hale getir.
5. **Audio & Speech System** – `PoliticianSpeech.gd` için ses klipleri, ses çalma yönetimi ve ses‑mesafe attenuation ayarlarını tamamla.

---

*Bu rapor, Godot 4’te büyük ölçekli kalabalık simülasyonu için temel mimariyi ve uygulanması gereken kritik adımları içermektedir.*