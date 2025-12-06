extends "res://scripts/enemy.gd"

func _get_movement_velocity(delta: float) -> Vector2:
	# Bat behavior: Steer towards hero (Swooping)
	# Current desired velocity
	var direction_to_player = global_position.direction_to(hero.global_position)
	var desired_velocity = direction_to_player * speed
	
	# Steer from current velocity to desired velocity
	# The lower the weight (0.05), the wider the turn. 
	# The higher (0.5), the sharper the turn.
	var steering = velocity.lerp(desired_velocity, 2.0 * delta)
	
	return steering
