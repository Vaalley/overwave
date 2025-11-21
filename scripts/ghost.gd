extends CharacterBody2D

const SPEED = 50.0
var player = null

var xp_gem_scene = preload("res://xp_gem.tscn")
var health = 1

func _physics_process(_delta: float):
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		if not player:
			return
	
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	move_and_slide()

func take_damage():
	health -= 1
	if health <= 0:
		die()

func die():
	var gem_instance = xp_gem_scene.instantiate()
	gem_instance.global_position = global_position
	get_tree().root.add_child(gem_instance)
	
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage(10.0) # Deal 10 damage
		queue_free()
