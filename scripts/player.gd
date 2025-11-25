class_name Player extends CharacterBody2D

@export var starting_weapon: WeaponData
var weapon_slot_scene = preload("res://weapon_slot.tscn")

signal health_changed(current_value, max_value)
signal player_died

# Health system
@export var max_health: float = 100.0
var health: float = 100.0

# AI movement
var ai_direction: Vector2 = Vector2.ZERO
var ai_timer: float = 0.0
@export var change_direction_interval: float = 2.0
@export var fear_radius: float = 100.0

# Movement speed
var SPEED = 80.0

func _ready() -> void:
	add_to_group("Player")
	add_weapon(starting_weapon)
	_pick_random_direction()

	GameManager.register_player(self)
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	ai_timer -= delta
	if ai_timer <= 0:
		_pick_random_direction()

	# Check for danger (enemies nearby)
	var danger = _get_flee_vector()

	# Decide Movement
	if danger != Vector2.ZERO:
		velocity = velocity.lerp(danger * SPEED * 1.2, 0.1)
	elif ai_direction != Vector2.ZERO:
		velocity = ai_direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if get_slide_collision_count() > 0:
		_pick_random_direction()

func _draw():
	# Draw a faint red circle to show the safe zone
	draw_circle(Vector2.ZERO, GameManager.safe_zone_radius, Color(1.0, 0.3, 0.3, 0.2))
	# Draw an outline
	draw_arc(Vector2.ZERO, GameManager.safe_zone_radius, 0, TAU, 32, Color(1.0, 0.3, 0.3, 0.8), 2.0)

func add_weapon(weapon_data: WeaponData):
	var new_slot = weapon_slot_scene.instantiate()
	$WeaponManager.add_child(new_slot)
	new_slot.init(weapon_data, self)

func apply_upgrade(upgrade: UpgradeData):
	match upgrade.type:
		UpgradeData.UpgradeType.PLAYER_SPEED:
			SPEED += upgrade.value
			print("Speed is now: ", SPEED)
			
		UpgradeData.UpgradeType.ATTACK_SPEED:
			for weapon_slot in $WeaponManager.get_children():
				weapon_slot.timer.wait_time *= upgrade.value
			print("All weapon fire rates multiplied by: ", upgrade.value)
			
func take_damage(amount: float):
	health -= amount
	print("Ouch! Health is: ", health)
	
	health_changed.emit(health, max_health)
	
	if health <= 0:
		die()

func die():
	player_died.emit()
	# For now, just restart the game instantly
	get_tree().reload_current_scene()

func _pick_random_direction():
	# Pick a random angle
	var angle = randf_range(0, TAU)
	ai_direction = Vector2.from_angle(angle)

	# Reset timer with some randomness
	ai_timer = randf_range(change_direction_interval * 0.5, change_direction_interval * 1.5)

func _get_flee_vector() -> Vector2:
	var enemies = get_tree().get_nodes_in_group("Enemy")
	var flee_vector = Vector2.ZERO
	var count = 0

	for enemy in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < fear_radius:
			# Vector away from enemy
			var away = (global_position - enemy.global_position).normalized()
			# Weight by distance (closer enemies matter more)
			flee_vector += away / dist
			count += 1

	if count > 0:
		return flee_vector.normalized()
	return Vector2.ZERO