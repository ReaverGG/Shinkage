extends Camera2D

@export var player: CharacterBody2D

func _process(delta: float) -> void:
	global_position = lerp(global_position, player.global_position, delta * 5)
