extends Node2D

var enemy_scene = preload("res://ghost.tscn")

func _on_timer_timeout() -> void:
	var enemy_instance = enemy_scene.instantiate()
	
	enemy_instance.global_position = Vector2(300, 200)
	add_child(enemy_instance)
