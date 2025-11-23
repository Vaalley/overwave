extends CanvasLayer

@onready var mana_bar = $ManaBar
@onready var health_bar = $HealthBar

func _ready():
	GameManager.mana_changed.connect(_on_mana_changed)
	
	# Wait for player to be ready
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		# Initialize bar
		health_bar.max_value = player.max_health
		health_bar.value = player.health

func _on_mana_changed(current_mana, max_mana):
	mana_bar.value = current_mana
	mana_bar.max_value = max_mana

func _on_player_health_changed(current, max_val):
	health_bar.value = current
	health_bar.max_value = max_val
