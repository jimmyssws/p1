extends Node

# WeatherController for Miting Oyunu
# Handles dynamic volumetric fog, rain particles and sky color transitions.
# Attach this script to a dedicated node in your main scene (e.g., WeatherRoot).

# --- Exported resources ---------------------------------------------------
@export var rain_particle_scene: PackedScene
@export var fog_environment: WorldEnvironment
@export var sky_material: ProceduralSkyMaterial
@export var projector_lights: Array[NodePath] = []

# --- Configurable parameters ---------------------------------------------
@export_range(0.0, 1.0, 0.01) var fog_density_min: float = 0.0
@export_range(0.0, 1.0, 0.01) var fog_density_max: float = 0.5
@export_range(0.0, 1.0, 0.01) var fog_density_speed: float = 0.1

@export_range(0.0, 1.0, 0.01) var rain_chance: float = 0.3  # % chance to start rain each check
@export var rain_check_interval: float = 5.0          # seconds

@export var sky_color_day: Color = Color(0.5, 0.7, 1.0)
@export var sky_color_night: Color = Color(0.02, 0.02, 0.1)
@export var sky_transition_speed: float = 0.05

# --- Internal state -------------------------------------------------------
var _rain_instance: Node = null
var _current_fog_density: float = 0.0
var _target_fog_density: float = 0.0
var _time_since_last_check: float = 0.0
var _is_raining: bool = false

func _ready() -> void:
    # Initialize fog and sky
    if fog_environment and fog_environment.environment:
        fog_environment.environment.fog_density = fog_density_min
    if sky_material:
        sky_material.sky_top_color = sky_color_day
        sky_material.sky_horizon_color = sky_color_day.lerp(sky_color_night, 0.5)
    # Start periodic rain check
    set_process(true)

func _process(delta: float) -> void:
    _update_fog(delta)
    _update_sky(delta)
    _rain_check(delta)

# -------------------------------------------------------------------------
# Fog handling
func _update_fog(delta: float) -> void:
    if _current_fog_density != _target_fog_density:
        var diff = _target_fog_density - _current_fog_density
        var step = fog_density_speed * delta
        if abs(diff) <= step:
            _current_fog_density = _target_fog_density
        else:
            _current_fog_density += step * sign(diff)
        if fog_environment and fog_environment.environment:
            fog_environment.environment.fog_density = _current_fog_density
        _update_projector_intensity()

func set_fog_density(target: float) -> void:
    _target_fog_density = clamp(target, fog_density_min, fog_density_max)

# -------------------------------------------------------------------------
# Sky color transition based on "coşku" (excitement) – here simulated by time of day.
func _update_sky(delta: float) -> void:
    # Simple day/night cycle: oscillate with a sine wave (0..1)
    var time_factor = (sin(OS.get_ticks_msec() / 10000.0) + 1.0) / 2.0
    var target_color = sky_color_day.lerp(sky_color_night, 1.0 - time_factor)
    if sky_material:
        sky_material.sky_top_color = sky_material.sky_top_color.lerp(target_color, sky_transition_speed * delta)
        sky_material.sky_horizon_color = sky_material.sky_horizon_color.lerp(target_color, sky_transition_speed * delta)

# -------------------------------------------------------------------------
# Rain handling
func _rain_check(delta: float) -> void:
    _time_since_last_check += delta
    if _time_since_last_check >= rain_check_interval:
        _time_since_last_check = 0.0
        if not _is_raining and randf() < rain_chance:
            start_rain()
        elif _is_raining and randf() > rain_chance:
            stop_rain()

func start_rain() -> void:
    if not rain_particle_scene:
        push_error("Rain particle scene not assigned!")
        return
    _rain_instance = rain_particle_scene.instantiate()
    add_child(_rain_instance)
    _is_raining = true
    # Increase fog slightly when it rains
    set_fog_density(fog_density_max)

func stop_rain() -> void:
    if _rain_instance and is_instance_valid(_rain_instance):
        _rain_instance.queue_free()
    _rain_instance = null
    _is_raining = false
    # Reduce fog back to minimum
    set_fog_density(fog_density_min)

# -------------------------------------------------------------------------
# Projector light intensity adaption (e.g., spotlights, point lights)
func _update_projector_intensity() -> void:
    for path in projector_lights:
        var light = get_node_or_null(path)
        if light and light is Light3D:
            # Dim lights proportionally to fog density (more fog -> dimmer)
            var base_energy = 5.0  # you can expose this as export if needed
            light.light_energy = base_energy * (1.0 - _current_fog_density)
