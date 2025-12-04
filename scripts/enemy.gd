class_name Enemy extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: float = 10.0
@export var damage: float = 10.0

var health: float
var player: Node2D = null
var xp_gem_scene = preload("res://xp_gem.tscn")

func _ready() -> void:
	health = max_health
	add_to_group("Enemy")
	
	# Try to find player immediately
	if GameManager.player_ref:
		player = GameManager.player_ref
	else:
		player = get_tree().get_first_node_in_group("Player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		# Try to find player via GameManager if reference lost
		if GameManager.player_ref:
			player = GameManager.player_ref
		else:
			return
	
	velocity = _get_movement_velocity(delta)
	move_and_slide()

func _get_movement_velocity(_delta: float) -> Vector2:
	# Default behavior: Move straight to player
	var direction = global_position.direction_to(player.global_position)
	return direction * speed

func take_damage(amount: float) -> void:
	health -= amount
	SoundManager.play_sfx("enemy_hit")
	
	# Visual feedback (Hit flash/bounce)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)
	
	if health <= 0:
		call_deferred("die")

func die() -> void:
	SoundManager.play_sfx("enemy_die")
	var gem_instance = xp_gem_scene.instantiate()
	gem_instance.global_position = global_position
	get_tree().root.add_child(gem_instance)
	
	queue_free()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
