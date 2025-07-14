extends CharacterBody2D

@onready var vida: Node2D = $Vida
@onready var movimiento: Node2D = $Movimiento
@onready var arma: Node2D = $Arma
@export var speed := 50
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var vision: RayCast2D = $Vision/RayCast2D

@export var player_path := NodePath("")
@onready var dadaso := preload("res://escenas/dadaso.tscn")
@onready var maquina_estado: Node = $MaquinaEstado
@onready var jugador := get_node(player_path)


func _ready():
	jugador = get_node(player_path)
	maquina_estado.jugador = jugador
	# Conectamos señales
	vida.connect("part_disabled", Callable(self, "_on_part_disabled"))
	vida.connect("died", Callable(self, "_on_died"))
	vida.connect("damaged", Callable(self, "_on_damaged"))
	
func _process(delta):
	pass
func _physics_process(delta):
	if not player:
		return

	var direction_to_player = (jugador.global_position - global_position).normalized()
	vision.target_position = direction_to_player * 50 # o más largo si querés
	# Forzamos el raycast a recalcular
	vision.force_raycast_update()

	# Usamos el raycast para detectar si ve al jugador
	if vision.is_colliding() and vision.get_collider() == jugador:
		arma.target_node = jugador
		arma.try_shoot()
	else:
		arma.target_node = null
		
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
	queue_free()
	
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

func soltar_arma():
	if arma.has_method("desactivar"):
		arma.desactivar()
	
	print("🔫 Arma destruida")

func notificar_jugador_muerto():
	jugador = null
