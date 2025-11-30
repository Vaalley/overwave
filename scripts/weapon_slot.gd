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
	var target = _get_closest_enemy()
	
	if target:
		_fire_at(target)

func _get_closest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.is_empty():
		return null

	var closest_enemy: Node2D = null
	var closest_distance = INF

	for enemy in enemies:
		var dist = player.global_position.distance_squared_to(enemy.global_position)
		if dist < closest_distance:
			closest_distance = dist
			closest_enemy = enemy

	return closest_enemy

func _fire_at(target: Node2D):
	var projectile = weapon_data.projectile_scene.instantiate()
	projectile.global_position = player.global_position
	
	var direction = (target.global_position - player.global_position).normalized()
	projectile.velocity = direction
	projectile.rotation = direction.angle()
	
	get_tree().current_scene.add_child(projectile)
	SoundManager.play_sfx("hero_shoot")
