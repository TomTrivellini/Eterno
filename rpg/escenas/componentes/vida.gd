extends Node2D
signal died()
signal damaged(part: String, amount: int, remaining: int)
signal part_disabled(part: String)

@export var limbs = {
	"head": 5,
	"torso": 5,
	"arms": 5,
	"legs": 5,
}
const MAX_LIMB_HEALTH = 5
# Estado actual (si están inhabilitados)

var disabled_limbs = {
	"head": false,
	"torso": false,
	"arms": false,
	"legs": false,
}


func _ready():
	reset()
	connect("part_disabled", Callable(self, "_on_part_disabled"))
func reset():
	for limb in limbs.keys():
		limbs[limb] = MAX_LIMB_HEALTH
		disabled_limbs[limb] = false

func apply_damage_to_limb(limb: String, amount: int):
	if !limbs.has(limb):
		print("❌ Parte inválida:", limb)
		return

	limbs[limb] -= amount
	limbs[limb] = clamp(limbs[limb], 0, MAX_LIMB_HEALTH)

	if limbs[limb] <= 0 and !disabled_limbs[limb]:
		disabled_limbs[limb] = true
		print("💥 Parte inhabilitada:", limb)

	check_death()
	
func apply_dice_result(result: int):
	if result == 1:
		print("🛡️ ¡Esquivado!")
		return
	
	elif result == 6:
		# Headshot crítico
		limbs["arms"] = 0
		disabled_limbs["arms"] = true
		emit_signal("damaged", "arms", MAX_LIMB_HEALTH, 0)
		print("💥 armeado gil!")
		check_death()
		return
	
	# Resultado 2–5 → Daño a una parte aleatoria
	var parts = ["head", "torso", "arms", "legs"]
	var chosen = parts[randi_range(0, parts.size() - 1)]
	var damage = result

	# Aplicar daño directamente
	limbs[chosen] = max(limbs[chosen] - damage, 0)
	emit_signal("damaged", chosen, damage, limbs[chosen])

	# Si la parte quedó en 0 y no estaba marcada como inhabilitada:
	if limbs[chosen] <= 0 and !disabled_limbs[chosen]:
		disabled_limbs[chosen] = true
		emit_signal("part_disabled", chosen)
	
	check_death()

func check_death():
	if limbs["head"] <= 0 or limbs["torso"] <= 0:
		emit_signal("died")

func _on_part_disabled(part: String):
	match part:
		"arms":
			print("🦾 ¡Brazos inutilizados!")
			# Avisar al nodo padre que suelte el arma (si tiene)
			if get_parent().has_method("soltar_arma"):
				get_parent().soltar_arma()
		"legs":
			print("🦿 Piernas dañadas. Reducción de velocidad.")
			# Avisar al componente de movimiento (si existe)
			if get_parent().has_node("movimiento"):
				get_parent().get_node("movimiento").adjust_speed_on_leg_damage()
