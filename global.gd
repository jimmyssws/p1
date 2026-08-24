extends Node

var network_mode: String = "HOST"
var join_ip: String = "127.0.0.1"
var master_volume: float = 0.85
var sfx_volume: float = 0.85

func _ready():
	_apply_master_volume(master_volume)

func set_volume(val: float):
	master_volume = clamp(val, 0.0, 1.0)
	_apply_master_volume(master_volume)

func _apply_master_volume(val: float):
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		if val <= 0.01:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			var db = linear_to_db(val)
			AudioServer.set_bus_volume_db(bus_idx, db)
