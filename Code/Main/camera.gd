extends Camera2D

@export var player: CharacterBody2D

var camera_speed: float = 15.0

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, player.global_position, delta * camera_speed)
