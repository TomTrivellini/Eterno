extends Node2D

@onready var sprite := $Sprite2D
@onready var bullet_scene := preload("res://escenas/bullet.tscn")
@onready var cañon := $Marker2D
@onready var anim: AnimationPlayer = $Sprite2D/AnimationPlayer
@export var is_player := false
var can_shoot := true
@export var target_node: Node2D  # el objetivo a apuntar (jugador)

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	look_at(mouse_pos)
	
	if is_player:
		look_at(get_global_mouse_position())
		# Flip del sprite si el mouse está a la izquierda
		var is_mouse_left = mouse_pos.x < global_position.x
		sprite.flip_v = is_mouse_left  # vertical porque el sprite rota con el arma
	elif target_node and is_instance_valid(target_node):
		look_at(target_node.global_position)
		var is_player_left = target_node.global_position.x < global_position.x
		sprite.flip_v = is_player_left

	else:
		# Si no hay objetivo, suavemente vuelve a rotar a 0 (apuntando hacia la derecha)
		rotation = lerp_angle(rotation, 0.0, delta * 3)
		sprite.flip_v = false
func try_shoot():
	if not can_shoot:
		return
	if not is_player and not target_node:
		return

	can_shoot = false
	anim.play("shoot")  # 👉 Disparo controlado por animación
	await anim.animation_finished
	can_shoot = true

func shoot():
	if !bullet_scene:
		print("No hay bala asignada")
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = cañon.global_position
	bullet.rotation = rotation
	get_tree().current_scene.add_child(bullet)

func desactivar():
	queue_free()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		can_shoot = true
