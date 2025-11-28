extends CanvasLayer

@onready var mana_bar = $ManaBar
@onready var health_bar = $HealthBar
@onready var timer_label = $TimerLabel

@onready var game_over_panel = $GameOverPanel
@onready var result_label = $GameOverPanel/ResultLabel
@onready var restart_button = $GameOverPanel/RestartButton
@onready var unit_panels: Array[Control] = [
	$UnitSelector/UnitPanel0,
	$UnitSelector/UnitPanel1,
	$UnitSelector/UnitPanel2
]

func _ready():
	GameManager.mana_changed.connect(_on_mana_changed)
	GameManager.time_updated.connect(_on_time_updated)
	GameManager.game_ended.connect(_on_game_ended)

	restart_button.pressed.connect(_on_restart_pressed)

	game_over_panel.visible = false
	
	# Wait for player to be ready
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.health_changed.connect(_on_player_health_changed)
		health_bar.max_value = player.max_health
		health_bar.value = player.health
	
	# Connect to unit changes
	GameManager.unit_changed.connect(_on_unit_changed)
	
	# Initialize with current selection (0)
	_update_unit_selection(0)

func _on_mana_changed(current_mana, max_mana):
	mana_bar.value = current_mana
	mana_bar.max_value = max_mana

func _on_player_health_changed(current, max_val):
	health_bar.value = current
	health_bar.max_value = max_val

func _on_time_updated(time_left: float):
	timer_label.text = str(ceil(time_left))

func _on_game_ended(player_won: bool):
	game_over_panel.visible = true
	if player_won:
		result_label.text = "VICTORY\n(Hero Defeated)"
		result_label.modulate = Color.GREEN
	else:
		result_label.text = "DEFEAT\n(Hero Escaped)"
		result_label.modulate = Color.RED

func _on_restart_pressed():
	get_tree().reload_current_scene()
	GameManager.reset_game()

func _on_unit_changed(index: int, _name: String, _cost: float) -> void:
	_update_unit_selection(index)

func _update_unit_selection(selected_index: int) -> void:
	for i in range(unit_panels.size()):
		var panel = unit_panels[i]
		if i == selected_index:
			panel.modulate = Color.WHITE
		else:
			panel.modulate = Color(0.5, 0.5, 0.5, 0.8)
