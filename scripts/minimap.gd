extends Control

var player_ref: CharacterBody3D = null
var drone_pos: Vector3 = Vector3.ZERO
var show_drone: bool = false

const MAP_MIN = Vector2(-40.0, -45.0)
const MAP_MAX = Vector2(40.0, 45.0)
const MAP_PX  = Vector2(105.0, 105.0)

const TASK_ZONES = [
	{"pos": Vector2(0.0, -27.0),  "icon": "🎙", "col": Color(0.4, 0.7, 1.0)},
	{"pos": Vector2(0.0, -21.0),  "icon": "🤝", "col": Color(0.25, 0.85, 0.35)},
	{"pos": Vector2(24.0, -8.0),  "icon": "🎥", "col": Color(0.95, 0.3, 0.3)},
]

func _process(_delta):
	queue_redraw()

func _draw():
	var bg = Color(0.04, 0.06, 0.12, 0.75)
	draw_rect(Rect2(Vector2.ZERO, MAP_PX), bg)
	draw_rect(Rect2(Vector2.ZERO, MAP_PX), Color(0.38, 0.55, 0.9, 0.45), false, 1.5)

	var font = ThemeDB.fallback_font

	for zone in TASK_ZONES:
		var sp = _w2m(zone.pos)
		draw_circle(sp, 5.0, zone.col * Color(1, 1, 1, 0.35))
		draw_circle(sp, 5.0, zone.col, false)
		draw_string(font, sp + Vector2(-6, 4), zone.icon, HORIZONTAL_ALIGNMENT_LEFT, -1, 11)

	if show_drone and is_instance_valid(player_ref):
		var dp = _w2m(Vector2(drone_pos.x, drone_pos.z))
		draw_circle(dp, 5.0, Color(1.0, 0.85, 0.2, 0.9))
		draw_string(font, dp + Vector2(-8, -6), "🚁", HORIZONTAL_ALIGNMENT_LEFT, -1, 12)

	if is_instance_valid(player_ref):
		var wp = player_ref.global_position
		var sp = _w2m(Vector2(wp.x, wp.z))
		draw_circle(sp, 6.0, Color(1, 1, 1, 0.95))
		draw_circle(sp, 6.0, Color(0.2, 0.2, 0.2), false)

	draw_string(font, Vector2(MAP_PX.x * 0.5 - 4, 11), "N", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(0.6, 0.7, 0.95))
	draw_string(font, Vector2(2, MAP_PX.y - 3), "HARITA", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.35, 0.45, 0.65))

func _w2m(xz: Vector2) -> Vector2:
	var t = (xz - MAP_MIN) / (MAP_MAX - MAP_MIN)
	t.y = 1.0 - t.y
	return t * MAP_PX
