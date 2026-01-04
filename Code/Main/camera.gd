extends Camera2D

@export var player: CharacterBody2D

var camera_speed: float = 6.7
var camera_x_follow_distance: float = 70.0
var camera_y_follow_distance: float = 20.0
var x_distance_multiplier: float = 0.0
var zoom_level: float = 1
var v_dir: int = 0
var screen_margin_ratio: float = 0.1

func _ready() -> void:
	position_smoothing_enabled = false
	global_position = player.global_position
	await get_tree().physics_frame
	position_smoothing_enabled = true
	
func _physics_process(_delta: float) -> void:
	v_dir = sign(player.velocity.y)
	camera_y_follow_distance = abs(player.velocity.y) / 15
	
	if abs(player.velocity.x) < player.WALK_THRESHOLD: 
		x_distance_multiplier = 0.0
	else: 
		x_distance_multiplier = 1.0

func _process(delta: float) -> void:
	zoom = Vector2(zoom_level, zoom_level)
	
	var target_pos: Vector2
	
	if player.active_state == player.STATE.LEDGE_CLIMB:
		target_pos = Vector2(
			player.climb_marker.global_position.x, 
			player.climb_marker.global_position.y - player.collider.shape.height / 2
		)
		var blend = 1.0 - exp(-camera_speed * 1.5 * delta)
		global_position = global_position.lerp(target_pos, blend)
		
	elif player.active_state == player.STATE.WALL_JUMP:
		target_pos = Vector2(
			player.global_position.x + camera_x_follow_distance * x_distance_multiplier * player.last_direction\
			 * abs(player.x_velocity), player.global_position.y + camera_y_follow_distance * v_dir
		)
	else:
		target_pos = Vector2(
			player.global_position.x + camera_x_follow_distance * x_distance_multiplier * player.input_direction\
			* abs(player.x_velocity), 
			player.global_position.y + camera_y_follow_distance * v_dir
		)
		var blend = 1.0 - exp(-camera_speed * delta)
		global_position = global_position.lerp(target_pos, blend)

	enforce_bounds()

func enforce_bounds() -> void:
	var visible_size = get_viewport_rect().size / zoom
	var limit_x = visible_size.x * screen_margin_ratio
	var limit_y = visible_size.y * screen_margin_ratio
	
	var diff = player.global_position - global_position
	
	if abs(diff.x) > limit_x:
		global_position.x += diff.x - (sign(diff.x) * limit_x)
	if abs(diff.y) > limit_y:
		global_position.y += diff.y - (sign(diff.y) * limit_y)
