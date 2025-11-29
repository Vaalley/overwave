extends "res://scripts/enemy.gd"

var is_enraged: bool = false
var enraged_speed_multiplier: float = 2.0

func take_damage(amount: float) -> void:
	super.take_damage(amount)
	
	# Enrage mechanic: Speed up when hit!
	if not is_enraged and health > 0:
		is_enraged = true
		speed *= enraged_speed_multiplier
		modulate = Color(1, 0.5, 0.5)
		
		# Create a timer to calm down
		var timer = get_tree().create_timer(2.0)
		timer.timeout.connect(_calm_down)

func _calm_down() -> void:
	if health > 0:
		speed /= enraged_speed_multiplier
		is_enraged = false
		modulate = Color.WHITE
