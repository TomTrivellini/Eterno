extends Node2D
@onready var label: Label = $Label
@onready var tween := create_tween()

func _show(value: int, start_pos: Vector2):
	global_position = start_pos
	label.text = str(value)

	# Subir + desvanecer en 1 segundo
	tween.tween_property(self, "position:y", position.y - 30, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "modulate:a", 0.0, 1.0)

	await tween.finished
	queue_free()
