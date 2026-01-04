extends CharacterBody2D
class_name Player

enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	IDLE_ATTACK,
	RUN_ATTACK,
	AIR_ATTACK,
	IDLE_THROW,
	RUN_THROW,
	SPECIAL_ATTACK,
	AIR_DASH,
	GROUND_DASH,
	WALL_SLIDE,
	WALL_JUMP,
	LEDGE_GRAB,
	LEDGE_CLIMB,
}

var can_dash: bool = false
var can_special_attack: bool = false
var can_shuriken_attack: bool = false
var can_double_jump: bool = false
var can_wall_jump: bool = false

var active_state: STATE = STATE.FALL
var previous_state: STATE = active_state
var input_direction: float = 0.0
var last_direction: float = 1.0
var x_velocity: float = 0.0
var ledge_hook_distance: float = 20.0
var last_saved_x_position: float = 0.0

const GRAVITY: float = 1500.0
const FALL_SPEED: float = 430.0
const JUMP_FORCE: float = 460.0
const JUMP_CUT_MULTIPLIER: float = 0.567
const WALL_SLIDE_SPEED: float = 80.0
const WALL_SLIDE_ACCEL: float = 100.0
const WALL_JUMP_FORCE: Vector2 = Vector2(50, -90)
const WALL_JUMP_LENGTH: float = 20.0
const LEDGE_SNAP_SPEED: float = 200.0

const MOVE_SPEED: float = 150.0
const MOVE_ACCELERATION: float = 1700.0
const MOVE_DECELERATION: float = 1100.0

const WALK_THRESHOLD: float = 44.0
const RUN_THRESHOLD: float = 120.0

@export_category("References")
@export_group("Essentials")
@export var animator: AnimationPlayer
@export var squash: AnimationPlayer
@export var sprite_node: Node2D
@export var sprite: Sprite2D
@export var collider: CollisionShape2D
@export_group("Checkers")
@export var right_floor_ray: RayCast2D
@export var left_floor_ray: RayCast2D
@export var top_ray: RayCast2D
@export var top_wall_slide_ray: RayCast2D
@export var bottom_wall_slide_ray: RayCast2D
@export var ledge_hook: CollisionShape2D
@export var climb_marker: Marker2D
@export_group("Timers")
@export var coyote_timer: Timer
@export var jump_buffer_timer: Timer

func _ready() -> void:
	switch_state(active_state)
	
func _physics_process(delta: float) -> void:
	process_state(delta)
	if ledge_hook.position.x != last_direction * ledge_hook_distance:
		ledge_hook.position.x = last_direction * ledge_hook_distance
		
	# Ledge Hook
	var is_falling: bool = (active_state == STATE.FALL)
	var head_is_clear: bool = !top_ray.is_colliding() and (!right_floor_ray.is_colliding()\
	and !left_floor_ray.is_colliding())
	if !Input.is_action_pressed("down"):
		ledge_hook.disabled = not (is_falling and head_is_clear)
	else:
		ledge_hook.disabled = true
	
	move_and_slide()

func switch_state(to_state: STATE) -> void:
	previous_state = active_state
	active_state = to_state
	match active_state:
		STATE.FALL:
			animator.play("jump_transition")
		STATE.FLOOR:
			if previous_state == STATE.LEDGE_CLIMB:
				animator.play("idle")
				global_position = Vector2(climb_marker.global_position.x, \
				climb_marker.global_position.y - collider.shape.height / 2)
				reset_physics_interpolation()
		STATE.JUMP:
			animator.play("jump_start")
			squash.play("squash")
			velocity.y = -JUMP_FORCE
		STATE.WALL_SLIDE:
			velocity = Vector2.ZERO
			last_saved_x_position = global_position.x
			animator.play("wall_contact")
		STATE.LEDGE_GRAB:
			velocity = Vector2.ZERO
			animator.play("ledge_grab")
		STATE.LEDGE_CLIMB:
			animator.play("ledge_climb")
		STATE.WALL_JUMP:
			animator.play("wall_jump")
func process_state(delta: float) -> void:
	match active_state:
		STATE.FALL:
			handle_movement(delta)
			velocity.y = move_toward(velocity.y, FALL_SPEED, GRAVITY * delta)
			if is_on_floor():
				if right_floor_ray.is_colliding() or left_floor_ray.is_colliding():
					switch_state(STATE.FLOOR)
				else:
					switch_state(STATE.LEDGE_GRAB)
			if !coyote_timer.is_stopped():
				if Input.is_action_just_pressed("jump"):
					coyote_timer.stop()
					switch_state(STATE.JUMP)
			if Input.is_action_just_pressed("jump"):
				jump_buffer_timer.start()
			if can_wall_slide():
				switch_state(STATE.WALL_SLIDE)
		STATE.FLOOR:
			handle_movement(delta)
			if abs(velocity.x) < WALK_THRESHOLD:
				animator.play("idle")
			elif abs(velocity.x) < RUN_THRESHOLD:
				animator.play("walk")
			else:
				animator.play("run")
			if Input.is_action_just_pressed("jump")\
			or (Input.is_action_pressed("jump") and !jump_buffer_timer.is_stopped()):
				jump_buffer_timer.stop()
				switch_state(STATE.JUMP)
			if !is_on_floor():
				coyote_timer.start()
				switch_state(STATE.FALL)
		STATE.JUMP:
			handle_movement(delta)
			velocity.y = move_toward(velocity.y, 0, GRAVITY * delta)
			if velocity.y >= 0:
				switch_state(STATE.FALL)
			if Input.is_action_just_released("jump"):
				velocity.y *= JUMP_CUT_MULTIPLIER
				switch_state(STATE.FALL)
		STATE.WALL_SLIDE:
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, WALL_SLIDE_ACCEL * delta)
			handle_movement(delta)
			if is_on_floor():
				switch_state(STATE.FLOOR)
			elif !is_on_wall_only() or !bottom_wall_slide_ray.is_colliding():
				switch_state(STATE.FALL)
			if Input.is_action_pressed("down"):
				switch_state(STATE.FALL)
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.WALL_JUMP)
		STATE.LEDGE_GRAB:
			if !is_on_wall():
				global_position.x += last_direction * delta * LEDGE_SNAP_SPEED
			var current_input = signf(Input.get_axis("left", "right"))
			if current_input != 0 and current_input != last_direction:
				ledge_hook.disabled = true
				velocity.x = current_input * MOVE_SPEED
				last_direction = current_input
				switch_state(STATE.FALL)
			if Input.is_action_pressed("jump"):
				switch_state(STATE.LEDGE_CLIMB)
			if Input.is_action_just_pressed("down"):
				ledge_hook.disabled = true
				switch_state(STATE.FALL)
		STATE.LEDGE_CLIMB:
			if !is_on_wall():
				global_position.x += last_direction * delta * LEDGE_SNAP_SPEED
			if !animator.is_playing():
				if Input.is_action_pressed("jump"):
					global_position = Vector2(climb_marker.global_position.x, \
					climb_marker.global_position.y - collider.shape.height / 2)
					reset_physics_interpolation()
					switch_state(STATE.JUMP)
				else:
					switch_state(STATE.FLOOR)
		STATE.WALL_JUMP:
			if last_saved_x_position + WALL_JUMP_LENGTH * last_direction - global_position.x > 0:
				velocity = WALL_JUMP_FORCE
			
func handle_movement(delta: float) -> void:
	flip_sprite()
	var axis: float = Input.get_axis("left", "right")
	if axis != 0:
		if abs(axis * MOVE_SPEED) < RUN_THRESHOLD:
			axis = signf(axis) * (WALK_THRESHOLD / MOVE_SPEED)
		else:
			axis = signf(axis)
	if axis != 0 and velocity.x != 0 and signf(axis) != signf(velocity.x):
		velocity.x *= -1
	input_direction = signf(axis)
	x_velocity = axis
	if axis != 0:
		velocity.x = move_toward(velocity.x, axis * MOVE_SPEED, MOVE_ACCELERATION * delta)
		last_direction = input_direction
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_DECELERATION * delta)
		
func flip_sprite() -> void:
	if input_direction:
		sprite_node.scale.x = input_direction

func can_wall_slide() -> bool:
	return top_ray.is_colliding() and !(left_floor_ray.is_colliding()\
	and right_floor_ray.is_colliding()) and is_on_wall_only() and top_wall_slide_ray.is_colliding()\
	and !Input.is_action_pressed("down") and bottom_wall_slide_ray.is_colliding()
