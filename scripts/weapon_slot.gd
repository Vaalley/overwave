extends Node

@onready var timer = $Timer
var weapon_data: WeaponData
var player = null

func init(data: WeaponData, player_node: Node2D):
	weapon_data = data
	player = player_node

	timer.wait_time = weapon_data.cooldown
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	var p = weapon_data.projectile_scene.instantiate()
	p.global_position = player.global_position
	
	var direction = (player.get_global_mouse_position() - player.global_position).normalized()
	p.velocity = direction
	p.rotation = direction.angle()
	
	get_tree().root.add_child(p)
