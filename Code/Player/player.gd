extends CharacterBody2D
class_name Player

enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	SWORD_ATTACK,
	SHURIKEN_ATTACK,
	SPECIAL_ATTACK,
	AIR_ATTACK,
	DASH,
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

const GRAVITY: float = 1500.0
const FALL_SPEED: float = 640.0
const JUMP_FORCE: float = 460.0
const JUMP_CUT_MULTIPLIER: float = 0.67
const WALL_SLIDE_SPEED: float = 100.0
const WALL_SLIDE_ACCEL: float = 100.0

const MOVE_SPEED: float = 150.0
const MOVE_ACCELERATION: float = 1700.0
const MOVE_DECELERATION: float = 1100.0

const WALK_THRESHOLD: float = 30.0
const RUN_THRESHOLD: float = 120.0

@export_category("References")
@export_group("Essentials")
@export var animator: AnimationPlayer
@export var squash: AnimationPlayer
@export var sprite_node: Node2D
@export var sprite: Sprite2D
@export var collider: CollisionShape2D
@export_group("Checkers")

func _ready() -> void:
	switch_state(active_state)
	
func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func switch_state(to_state: STATE) -> void:
	previous_state = active_state
	active_state = to_state
	match active_state:
		STATE.FALL:
			animator.play("jump_transition")
		STATE.JUMP:
			animator.play("jump_start")
			squash.play("squash")
			velocity.y = -JUMP_FORCE
		STATE.WALL_SLIDE:
			velocity = Vector2.ZERO
			animator.play("wall_contact")
		STATE.LEDGE_GRAB:
			velocity = Vector2.ZERO
			animator.play("ledge_grab")
		STATE.LEDGE_CLIMB:
			animator.play("ledge_climb")
			
func process_state(delta: float) -> void:
	match active_state:
		STATE.JUMP:
			handle_movement(delta)
			velocity.y = move_toward(velocity.y, 0, GRAVITY * delta)
			if velocity.y >= 0:
				switch_state(STATE.FALL)
			if Input.is_action_just_released("jump"):
				velocity.y *= JUMP_CUT_MULTIPLIER
				switch_state(STATE.FALL)
		STATE.FALL:
			handle_movement(delta)
			velocity.y = move_toward(velocity.y, FALL_SPEED, GRAVITY * delta)
			if is_on_floor():
				switch_state(STATE.FLOOR)
		STATE.FLOOR:
			handle_movement(delta)
			if abs(velocity.x) < WALK_THRESHOLD:
				animator.play("idle")
			elif abs(velocity.x) < RUN_THRESHOLD:
				animator.play("walk")
			else:
				animator.play("run")
			if Input.is_action_just_pressed("jump"):
				switch_state(STATE.JUMP)
			if !is_on_floor():
				switch_state(STATE.FALL)
				
func handle_movement(delta: float) -> void:
	flip_sprite()
	input_direction = Input.get_axis("left", "right")
	if input_direction:
		if abs(velocity.x) < abs(MOVE_SPEED - 50):
			velocity.x = move_toward(velocity.x, input_direction * MOVE_SPEED, MOVE_ACCELERATION * delta)
		else:
			velocity.x = MOVE_SPEED * input_direction
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_DECELERATION * delta)
	if input_direction:
		last_direction = input_direction
	
func flip_sprite() -> void:
	if input_direction:
		sprite_node.scale.x = input_direction
