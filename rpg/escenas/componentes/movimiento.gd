extends Node2D

@export var speed := 100
var direction := Vector2.ZERO
var speed_multiplier := 1.0

func set_direction(dir: Vector2):
	direction = dir.normalized()

func stop():
	direction = Vector2.ZERO

func set_speed_multiplier(value: float):
	speed_multiplier = clamp(value, 0.0, 1.0)  # evitar negativos
	
func get_velocity() -> Vector2:
	return direction * speed * speed_multiplier
	
func is_moving() -> bool:
	return direction.length() > 0
	
