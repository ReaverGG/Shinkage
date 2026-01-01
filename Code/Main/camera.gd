extends Camera2D

@export var player: CharacterBody2D

var camera_speed: float = 10.0
var camera_x_follow_distance: float = 70.0
var camera_y_follow_distance: float = 20.0
var x_distance_multiplier: float = 0.0
var v_dir: int = 0

func _physics_process(delta: float) -> void:
	v_dir = sign(player.velocity.y)
	
	global_position = lerp(global_position, Vector2(player.global_position.x + camera_x_follow_distance * x_distance_multiplier\
	* player.input_direction, player.global_position.y + camera_y_follow_distance * v_dir)\
	, delta * camera_speed)
	
	if abs(player.velocity.x) < player.WALK_THRESHOLD: x_distance_multiplier = 0.0
	else: x_distance_multiplier = 1.0
	
