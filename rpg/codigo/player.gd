class_name player extends CharacterBody2D

@export var speed := 100
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


@onready var arma: Node2D = $Arma
@onready var movimiento: Node2D = $Movimiento
@onready var vida: Node2D = $Vida

func _ready():
	vida.connect("damaged", _on_damaged)
	vida.connect("died", _on_died)

func _input(event):
	if event.is_action_pressed("shoot"):
		arma.try_shoot()

func _physics_process(_delta):
	# Este ejemplo es para un jugador
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	)

	if input_vector.length() > 0:
		movimiento.set_direction(input_vector)
	else:
		movimiento.stop()



	# Flip horizontal si va hacia la izquierda
	if input_vector.x != 0:
		anim.flip_h = input_vector.x < 0

	# Elegir animación
	if movimiento.is_moving():
		anim.play("walk")
	else:
		anim.play("idle")
		
	velocity = movimiento.get_velocity()
	move_and_slide()
func _on_bullet_hit():
	dice_roll()
	
func dice_roll():
	var result := randi_range(1, 6)
	print("🎲 Dado: ", result)
	vida.apply_dice_result(result)
	show_roll(result)

func _on_damaged(part, amount, remaining):
	print("🩸 Daño a ", part, ": ", amount, " (quedan ", remaining, ")")
	flash_damage()

func _on_died():
	print("☠️ Murió.")
	get_tree().call_group("enemies", "notificar_jugador_muerto")
	queue_free()
	get_tree().call_group("ui", "show_restart_button")
	

func show_roll(value):
	var float_label = preload("res://escenas/dadaso.tscn").instantiate()
	get_tree().current_scene.add_child(float_label)
	float_label._show(value, global_position + Vector2(0, -10))
	
func flash_damage():
	var times = 3
	var interval = 0.1
	for i in range(times):
		anim.visible = false
		await get_tree().create_timer(interval).timeout
		anim.visible = true
		await get_tree().create_timer(interval).timeout
		anim.modulate = Color(1, 0.3, 0.3)  # rojo
		await get_tree().create_timer(0.3).timeout
		anim.modulate = Color(1, 1, 1)  # color original
	
