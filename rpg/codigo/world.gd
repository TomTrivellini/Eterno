extends Node2D

@onready var restart_button: Button = $Interfaz/Button

func _ready():
	restart_button.visible = false  # Oculta el botón al comenzar
	
func show_restart_button():
	restart_button.visible = true

func _on_button_pressed() -> void:
	get_tree().reload_current_scene()
