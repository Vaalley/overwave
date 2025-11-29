extends Node

signal mana_changed(current_mana: float, max_mana: float)
signal time_updated(time_left)
signal game_ended(player_won) # true if player (God) won (Hero died)

# Mana related settings
@export var max_mana: float = 100.0
var current_mana: float
@export var mana_regen_rate: float = 3.5

# Time/duration settings
var time_elapsed: float = 0.0
@export var game_duration: float = 60.0

# Player settings
var player_ref: Node2D
@export var safe_zone_radius: float = 120.0

# Unit settings
var enemy_scenes: Array[PackedScene] = [
	preload("res://ghost.tscn"),
	preload("res://bat.tscn"),
	preload("res://cyclop.tscn"),
]
var enemy_costs: Array[float] = [10.0, 5.0, 25.0]
var enemy_names: Array[String] = ["Ghost", "Bat", "Cyclop"]
var selected_unit: int = 0

signal unit_changed(index: int, name: String, cost: float)

func _ready() -> void:
	current_mana = max_mana
	mana_changed.emit(current_mana, max_mana)

func _process(delta: float) -> void:
	time_elapsed += delta
	var time_left = max(0.0, game_duration - time_elapsed)
	time_updated.emit(time_left)

	if time_elapsed >= game_duration:
		_end_game(false)
		set_process(false)
		
	regenerate_mana(delta)

func _unhandled_input(event: InputEvent) -> void:
	# Unit Selection (1, 2, 3)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1:
			_select_unit(0)
		elif event.keycode == KEY_2:
			_select_unit(1)
		elif event.keycode == KEY_3:
			_select_unit(2)

	# Spawning
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cost = enemy_costs[selected_unit]
		if current_mana < cost:
			return
		if not is_instance_valid(player_ref):
			return

		var spawn_pos = player_ref.get_global_mouse_position()
		if spawn_pos.distance_to(player_ref.global_position) < safe_zone_radius:
			return

		spend_mana(cost)
		var new_enemy = enemy_scenes[selected_unit].instantiate()
		get_tree().current_scene.add_child(new_enemy)
		new_enemy.global_position = player_ref.get_global_mouse_position()

func _select_unit(index: int) -> void:
	if index >= 0 and index < enemy_scenes.size():
		selected_unit = index
		unit_changed.emit(index, enemy_names[index], enemy_costs[index])
		print("Selected unit: ", enemy_names[index], " (cost: ", enemy_costs[index], ")")
	
func _on_player_died() -> void:
	_end_game(true)
	set_process(false)

func _end_game(player_won: bool) -> void:
	print("Game ended! Player won: ", player_won)
	game_ended.emit(player_won)

func regenerate_mana(delta: float) -> void:
	current_mana += mana_regen_rate * delta
	current_mana = clamp(current_mana, 0, max_mana)
	mana_changed.emit(current_mana, max_mana)

func spend_mana(amount: float) -> void:
	current_mana -= amount
	current_mana = clamp(current_mana, 0, max_mana)
	mana_changed.emit(current_mana, max_mana)

func register_player(player_node):
	player_ref = player_node
	player_node.player_died.connect(_on_player_died)
	print("Player connected to Game Manager.")

func reset_game() -> void:
	time_elapsed = 0.0
	current_mana = max_mana
	set_process(true)
	mana_changed.emit(current_mana, max_mana)
