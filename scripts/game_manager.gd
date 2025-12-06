extends Node

#region Signals
signal mana_changed(current_mana: float, max_mana: float)
signal time_updated(time_left: float)
signal game_ended(player_won: bool) # true if player (God) won (Hero died)
signal unit_changed(index: int, name: String, cost: float)
#endregion

#region Configuration
@export_group("Economy")
@export var max_mana: float = 100.0
@export var mana_regen_rate: float = 3.5
var current_mana: float

@export_group("Game Settings")
@export var game_duration: float = 60.0
@export var safe_zone_radius: float = 120.0
var time_elapsed: float = 0.0

@export_group("Units")
var enemy_scenes: Array[PackedScene] = [
	preload("res://scenes/entities/ghost.tscn"),
	preload("res://scenes/entities/bat.tscn"),
	preload("res://scenes/entities/cyclops.tscn"),
]
var enemy_costs: Array[float] = [10.0, 5.0, 25.0]
var enemy_names: Array[String] = ["Ghost", "Bat", "Cyclop"]
var selected_unit: int = 0
var spawn_effect_scene = preload("res://scenes/components/spawn_effect.tscn")
#endregion

#region State
var hero_ref: Node2D
#endregion

func _ready() -> void:
	current_mana = max_mana
	mana_changed.emit(current_mana, max_mana)
	SoundManager.play_music("bgm")

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
		match event.keycode:
			KEY_1: _select_unit(0)
			KEY_2: _select_unit(1)
			KEY_3: _select_unit(2)

	# Spawning
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_spawn_at_mouse()

#region Spawning & Units
func _select_unit(index: int) -> void:
	if index >= 0 and index < enemy_scenes.size():
		selected_unit = index
		unit_changed.emit(index, enemy_names[index], enemy_costs[index])
		print("Selected unit: ", enemy_names[index], " (cost: ", enemy_costs[index], ")")

func _try_spawn_at_mouse() -> void:
	if not is_instance_valid(hero_ref): return

	var cost = enemy_costs[selected_unit]
	if current_mana < cost: return

	var spawn_pos = hero_ref.get_global_mouse_position()
	if spawn_pos.distance_to(hero_ref.global_position) < safe_zone_radius:
		return

	spend_mana(cost)
	_spawn_unit(selected_unit, spawn_pos)

func _spawn_unit(unit_index: int, position: Vector2) -> void:
	# Spawn effect
	var spawn_effect = spawn_effect_scene.instantiate()
	spawn_effect.global_position = position
	get_tree().current_scene.add_child(spawn_effect)
	
	# Spawn enemy
	var new_enemy = enemy_scenes[unit_index].instantiate()
	get_tree().current_scene.add_child(new_enemy)
	new_enemy.global_position = position
	
	SoundManager.play_sfx("enemy_spawn")
#endregion

#region Game Logic
func regenerate_mana(delta: float) -> void:
	current_mana += mana_regen_rate * delta
	current_mana = clamp(current_mana, 0, max_mana)
	mana_changed.emit(current_mana, max_mana)

func spend_mana(amount: float) -> void:
	current_mana -= amount
	current_mana = clamp(current_mana, 0, max_mana)
	mana_changed.emit(current_mana, max_mana)

func register_hero(hero_node: Node2D) -> void:
	hero_ref = hero_node
	if hero_node.has_signal("hero_died"):
		hero_node.hero_died.connect(_on_hero_died)
	print("Hero connected to Game Manager.")

func _on_hero_died() -> void:
	_end_game(true)
	set_process(false)

func _end_game(player_won: bool) -> void:
	print("Game ended! Player won: ", player_won)
	game_ended.emit(player_won)
	SoundManager.stop_music()
	if player_won:
		SoundManager.play_music("victory")
	else:
		SoundManager.play_sfx("game_over")

func reset_game() -> void:
	time_elapsed = 0.0
	current_mana = max_mana
	set_process(true)
	mana_changed.emit(current_mana, max_mana)
	SoundManager.play_music("bgm")
#endregion
