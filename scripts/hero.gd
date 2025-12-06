class_name Hero extends CharacterBody2D

#region Signals
signal health_changed(current_value: float, max_value: float)
signal hero_died
signal level_changed(new_level: int)
signal xp_changed(current_xp: int, max_xp: int)
#endregion

#region Configuration
@export_group("Weapon")
@export var starting_weapon: WeaponData
var weapon_slot_scene = preload("res://scenes/components/weapon_slot.tscn")

@export_group("Health")
@export var max_health: float = 100.0
var health: float = 100.0

@export_group("AI Settings")
@export var change_direction_interval: float = 2.0
@export var fear_radius: float = 100.0
@export var detect_xp_radius: float = 500.0
@export var move_speed: float = 70.0
#endregion

#region State Variables
var ai_direction: Vector2 = Vector2.ZERO
var ai_timer: float = 0.0

# Leveling
var current_xp: int = 0
var max_xp: int = 5
var level: int = 1
#endregion

func _ready() -> void:
	add_to_group("Hero")
	health = max_health
	
	if starting_weapon:
		add_weapon(starting_weapon)
		
	_pick_random_direction()

	GameManager.register_hero(self)
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	ai_timer -= delta
	if ai_timer <= 0:
		_pick_random_direction()

	# 1. Check for danger (Flee)
	var danger_vector = _get_flee_vector()
	
	# 2. Check for rewards (XP)
	var desire_vector = _get_xp_vector()

	# 3. Decide Movement
	if danger_vector != Vector2.ZERO:
		# Fleeing has highest priority and a speed boost
		velocity = velocity.lerp(danger_vector * move_speed * 1.2, 0.1)
		
	elif desire_vector != Vector2.ZERO:
		# Chasing XP has medium priority
		velocity = velocity.lerp(desire_vector * move_speed, 0.1)
		
	elif ai_direction != Vector2.ZERO:
		# Wandering has lowest priority
		velocity = ai_direction * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if get_slide_collision_count() > 0:
		_pick_random_direction()

func _draw() -> void:
	# Draw a faint red circle to show the safe zone
	draw_circle(Vector2.ZERO, GameManager.safe_zone_radius, Color(1.0, 0.3, 0.3, 0.2))
	# Draw an outline
	draw_arc(Vector2.ZERO, GameManager.safe_zone_radius, 0, TAU, 32, Color(1.0, 0.3, 0.3, 0.8), 2.0)

#region Combat & Stats
func add_weapon(weapon_data: WeaponData) -> void:
	var new_slot = weapon_slot_scene.instantiate()
	$WeaponManager.add_child(new_slot)
	new_slot.init(weapon_data, self)
			
func take_damage(amount: float) -> void:
	health -= amount
	print("Ouch! Health is: ", health)
	SoundManager.play_sfx("hero_hit")
	
	health_changed.emit(health, max_health)
	
	if health <= 0:
		die()

func heal(amount: float) -> void:
	health = min(health + amount, max_health)
	health_changed.emit(health, max_health)
	# SoundManager.play_sfx("heal") # Optional

func die() -> void:
	hero_died.emit()
	queue_free()
#endregion

#region Progression
func add_xp(amount: int) -> void:
	current_xp += amount
	SoundManager.play_sfx("xp_pickup")
	xp_changed.emit(current_xp, max_xp)

	if current_xp >= max_xp:
		level_up()

func level_up() -> void:
	SoundManager.play_sfx("level_up")
	current_xp -= max_xp
	level += 1
	max_xp = floor(max_xp * 1.5)
	xp_changed.emit(current_xp, max_xp)

	# Buff stats
	max_health += 10.0
	heal(5.0) # Heal a bit on level up
	move_speed += 5.0

	print("Hero Leveled Up! Lvl: ", level, " HP: ", max_health, " Speed: ", move_speed)
	level_changed.emit(level)

	# Check for double level up
	if current_xp >= max_xp:
		level_up()
#endregion

#region AI Logic
func _pick_random_direction() -> void:
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

func _get_xp_vector() -> Vector2:
	var gems = get_tree().get_nodes_in_group("XPGem")
	var closest_gem = null
	var min_dist = detect_xp_radius

	for gem in gems:
		var dist = global_position.distance_to(gem.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_gem = gem

	if closest_gem:
		return global_position.direction_to(closest_gem.global_position)
	return Vector2.ZERO
#endregion
