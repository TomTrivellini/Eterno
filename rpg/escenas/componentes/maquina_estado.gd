extends Node
var jugador: CharacterBody2D = null
var enemigo: CharacterBody2D = null

enum Estado { IDLE, ALERTA, BUSCAR, HUIDA }

var estado_actual = Estado.IDLE
var home_position := Vector2.ZERO
var posicion_inicial := Vector2.ZERO
@export var distancia_preferida := 150

func _ready():
	enemigo = get_parent()
	posicion_inicial = enemigo.global_position

func _physics_process(delta):
	print("Estado actual:", obtener_nombre_estado(estado_actual))
	if enemigo == null or jugador == null or !is_instance_valid(jugador):
		return
	
	match estado_actual:
		Estado.IDLE:
			if ve_al_jugador():
				cambiar_estado(Estado.ALERTA)

		Estado.ALERTA:
			if !ve_al_jugador():
				cambiar_estado(Estado.BUSCAR)
				return

			if enemigo.vida.disabled_limbs["arms"]:
				cambiar_estado(Estado.HUIDA)
				return

			var distancia = enemigo.global_position.distance_to(jugador.global_position)
			if distancia > distancia_preferida:
				var direccion = (jugador.global_position - enemigo.global_position).normalized()
				enemigo.movimiento.set_direction(direccion)
			else:
				enemigo.movimiento.set_direction(Vector2.ZERO)

			if enemigo.has_node("arma"):
				enemigo.arma.try_shoot()

		Estado.BUSCAR:
			var distancia = enemigo.global_position.distance_to(posicion_inicial)
			if distancia > 10:
				var direccion = (posicion_inicial - enemigo.global_position).normalized()
				enemigo.movimiento.set_direction(direccion)
			else:
				enemigo.movimiento.set_direction(Vector2.ZERO)
				cambiar_estado(Estado.IDLE)

		Estado.HUIDA:
			if enemigo.vida.disabled_limbs["legs"]:
				enemigo.movimiento.set_direction(Vector2.ZERO)
				return

			var direccion = (enemigo.global_position - jugador.global_position).normalized()
			enemigo.movimiento.set_direction(direccion)

func cambiar_estado(nuevo_estado):
	if estado_actual == nuevo_estado:
		return
	estado_actual = nuevo_estado
	print("🧠 Estado actual:", obtener_nombre_estado(estado_actual))

func obtener_nombre_estado(valor):
	for nombre in Estado.keys():
		if Estado[nombre] == valor:
			return nombre
	return "??"

func ve_al_jugador() -> bool:
	if enemigo.has_node("vision"):
		var ray = enemigo.get_node("vision")
		return ray.is_colliding() and ray.get_collider() == jugador
	return false
	
func get_state_name(val):
	for name in Estado.keys():
		if Estado[name] == val:
			return name
	return "??"

func sees_player() -> bool:
	if enemigo.has_node("vision"):
		var ray = enemigo.get_node("vision")
		return ray.is_colliding() and ray.get_collider() == player
	return false
