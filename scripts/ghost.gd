extends CharacterBody2D

const SPEED = 50.0
var player = null

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
