extends CanvasLayer

@onready var xp_bar = $XPBar
@onready var health_bar = $HealthBar

func _ready():
	ExperienceManager.xp_changed.connect(_on_xp_changed)
	ExperienceManager.level_up.connect(_on_level_up)
	
	xp_bar.value = ExperienceManager.current_xp
	xp_bar.max_value = ExperienceManager.xp_to_next_level
	
	# Wait for player to be ready
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		# Initialize bar
		health_bar.max_value = player.max_health
		health_bar.value = player.health

func _on_xp_changed(current_xp, xp_to_next_level):
	xp_bar.value = current_xp
	xp_bar.max_value = xp_to_next_level

func _on_level_up(_new_level):
	pass

func _on_player_health_changed(current, max_val):
	health_bar.value = current
	health_bar.max_value = max_val
