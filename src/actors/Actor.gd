class_name Actor
extends CharacterBody2D

@export var multiplayer_position: Vector2 = Vector2.ZERO 

const position_interpolation_speed = 10.0

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		multiplayer_position = global_position
	else:
		global_position = lerp(global_position, multiplayer_position, position_interpolation_speed * delta)
