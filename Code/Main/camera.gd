extends Camera2D

@export var player: CharacterBody2D

enum PlayerStates {
	WALL_CLIMB = 12,
}

var camera_speed: float = 10.0
var camera_x_follow_distance: float = 70.0
var camera_y_follow_distance: float = 20.0
var x_distance_multiplier: float = 0.0
var v_dir: int = 0

func _physics_process(delta: float) -> void:
	v_dir = sign(player.velocity.y)
	camera_y_follow_distance = abs(player.velocity.y) / 15
	if !player.active_state == PlayerStates.WALL_CLIMB:
		global_position = lerp(global_position, Vector2(player.global_position.x + camera_x_follow_distance * x_distance_multiplier\
		* player.input_direction, player.global_position.y + camera_y_follow_distance * v_dir)\
		, delta * camera_speed)
	else:
		global_position = lerp(global_position, Vector2(player.climb_marker.global_position.x, \
		player.climb_marker.global_position.y - player.collider.shape.height / 2), delta * camera_speed * 1.5)
	
	if abs(player.velocity.x) < player.WALK_THRESHOLD: x_distance_multiplier = 0.0
	else: x_distance_multiplier = 1.0
	
