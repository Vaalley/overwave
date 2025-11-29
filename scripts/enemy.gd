extends CharacterBody2D

@export var speed: float = 50.0
@export var max_health: float = 10.0
@export var damage: float = 10.0

var health: float
var player = null
var xp_gem_scene = preload("res://xp_gem.tscn")

func _ready():
	health = max_health
	
	add_to_group("Enemy")

func _physics_process(delta: float):
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		if not player:
			return
	
	velocity = _get_movement_velocity(delta)
	move_and_slide()

func _get_movement_velocity(_delta: float) -> Vector2:
	# Default behavior: Move straight to player
	var direction = global_position.direction_to(player.global_position)
	return direction * speed

func take_damage(amount):
	health -= amount
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property($Sprite2D, "scale", Vector2(1.0, 1.0), 0.1)
	
	if health <= 0:
		call_deferred("die")

func die():
	var gem_instance = xp_gem_scene.instantiate()
	gem_instance.global_position = global_position
	get_tree().root.add_child(gem_instance)
	
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(damage)
		queue_free()
