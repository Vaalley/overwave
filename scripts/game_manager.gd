extends Node

signal mana_changed(current_mana: float, max_mana: float)

var enemy_scene: PackedScene = preload("res://ghost.tscn")

# Mana related settings
@export var max_mana: float = 100.0
var current_mana: float
@export var mana_regen_rate: float = 2.0
@export var ghost_spawn_cost: float = 20.0

# Time/duration related settings
var time_elapsed: float = 0.0
@export var game_duration: float = 60.0

func _ready() -> void:
	current_mana = max_mana
	mana_changed.emit(current_mana, max_mana)
	
func _on_player_died() -> void:
	print("Player died! Victory!")
	set_process(false)
	# TODO: show win screen here?

func _process(delta: float) -> void:
	time_elapsed += delta
	if time_elapsed >= game_duration:
		print("Game over! Time's up.")
		set_process(false)
		
	regenerate_mana(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and current_mana >= ghost_spawn_cost:
		spend_mana(ghost_spawn_cost)
		var new_enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(new_enemy)
		new_enemy.global_position = new_enemy.get_global_mouse_position()
		print("Spawned ghost! Mana: ", current_mana, " / ", max_mana)

func regenerate_mana(delta: float) -> void:
	current_mana += mana_regen_rate * delta
	current_mana = clamp(current_mana, 0, max_mana)
	mana_changed.emit(current_mana, max_mana)

func spend_mana(amount: float) -> void:
	current_mana -= amount
	current_mana = clamp(current_mana, 0, max_mana)
	mana_changed.emit(current_mana, max_mana)

func register_player(player_node):
	player_node.player_died.connect(_on_player_died)
	print("Player connected to Game Manager.")
