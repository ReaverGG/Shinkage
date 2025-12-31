extends CharacterBody2D
class_name Player

enum STATE {
	FALL,
	FLOOR,
	JUMP,
	DOUBLE_JUMP,
	LEDGE_HANG,
	LEDGE_CLIMB,
	SWORD_ATTACK,
	SHURIKEN_ATTACK,
	SPECIAL_ATTACK,
	AIR_ATTACK,
	DASH,
	WALL_SLIDE,
	WALL_JUMP,
}

var can_dash: bool = false
var can_special_attack: bool = false
var can_shuriken_attack: bool = false
var can_double_jump: bool = false
var can_wall_jump: bool = false

var active_state: STATE = STATE.FALL
var previous_state: STATE = active_state
var input_direction: float = 0.0

const GRAVITY: float = 1500.0
const FALL_SPEED: float = 640.0

const MOVE_SPEED: float = 170.0
const MOVE_ACCELERATION: float = 1700.0
const MOVE_DECELERATION: float = 1100.0

const WALK_THRESHOLD: float = 30.0
const RUN_THRESHOLD: float = 120.0

@export_category("References")
@export_group("Essentials")
@export var animator: AnimationPlayer
@export var sprite: Sprite2D
@export var sprite_node: Node2D
@export var collider: CollisionShape2D

func _ready() -> void:
	switch_state(active_state)
	
func _physics_process(delta: float) -> void:
	process_state(delta)
	move_and_slide()

func switch_state(to_state: STATE) -> void:
	active_state = to_state
	match active_state:
		STATE.FALL:
			animator.play("jump_fall")

func process_state(delta: float) -> void:
	match active_state:
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
			
func handle_movement(delta: float) -> void:
	input_direction = Input.get_axis("left", "right")
	if input_direction:
		if abs(velocity.x) < abs(MOVE_SPEED - 50):
			velocity.x = move_toward(velocity.x, input_direction * MOVE_SPEED, MOVE_ACCELERATION * delta)
		else:
			velocity.x = MOVE_SPEED * input_direction
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_DECELERATION * delta)
	flip_sprite()
	
func flip_sprite() -> void:
	if input_direction:
		sprite_node.scale.x = input_direction
