extends Node2D

var enemy_scene = preload("res://ghost.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	# Spawn one enemy
	var enemy_instance = enemy_scene.instantiate()
	
	# (We'll get a real spawn point later. For now, just spawn it)
	enemy_instance.global_position = Vector2(300, 200) # Or any
	add_child(enemy_instance)
