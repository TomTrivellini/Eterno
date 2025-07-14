extends CanvasLayer

func _ready():
	$Button.visible = false
	
func show_restart_button():
	$Button.visible = true
