extends Area2D

@export var speed := 400
var direction := Vector2.ZERO
@onready var bullet: Area2D = $"."
var velocity := Vector2.ZERO 

func _ready():
	# Calcula la dirección en base a la rotación del nodo (seteada desde el arma)
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	set_as_top_level(true)  # Para evitar que herede transformaciones del arma

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	print("Colisionó con: ", body.name)
	if body.has_method("dice_roll"):
		body.dice_roll()
	_destroy()
	
func _destroy():
	queue_free()
