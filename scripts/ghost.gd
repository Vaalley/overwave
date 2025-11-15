extends CharacterBody2D

const SPEED = 50.0
var player = null

# Preload the gem scene
var xp_gem_scene = preload("res://xp_gem.tscn")
var health = 1 # The ghost can take 1 hit

func _physics_process(_delta: float):
	# If we don't have a player, try to find it.
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		# If we still can't find it (player might still be loading),
		# skip this frame.
		if not player:
			return
	
	# If we DO have a player, move towards it.
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED
	move_and_slide()

func take_damage():
	health -= 1
	if health <= 0:
		die()

func die():
	# Spawn a gem
	var gem_instance = xp_gem_scene.instantiate()
	gem_instance.global_position = global_position # Drop it where we died
	get_tree().root.add_child(gem_instance)
	
	# Now we die
	queue_free()
