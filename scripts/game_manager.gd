extends Node

@export var enemy_scene: PackedScene
@export var max_mana: int = 100
var current_mana: float
@export var ghost_spawn_cost: int = 20
@export var mana_regen_rate: float = 2.0

func _ready() -> void:
	current_mana = max_mana
	print("Current mana: ", current_mana)
	print("I am making this game!")

func _process(delta: float) -> void:
	current_mana += mana_regen_rate * delta
	current_mana = clamp(current_mana, 0, max_mana)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and current_mana >= ghost_spawn_cost:
		current_mana -= ghost_spawn_cost
		var new_enemy = enemy_scene.instantiate()
		get_tree().current_scene.add_child(new_enemy)
		new_enemy.global_position = new_enemy.get_global_mouse_position()
		print("Spawned ghost! Mana: ", current_mana, " / ", max_mana)
