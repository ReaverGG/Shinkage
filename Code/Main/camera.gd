extends Camera2D

@export var player: CharacterBody2D

var camera_speed: float = 10.0
var camera_follow_distance: float = 80.0

func _physics_process(delta: float) -> void:
	global_position = lerp(global_position, Vector2(player.global_position.x + camera_follow_distance * player.input_direction\
	,player.global_position.y), delta * camera_speed)
	
	if player.input_direction:
		camera_speed = 10.0
	else:
		camera_speed = 8.0
