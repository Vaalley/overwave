extends Area2D

const SPEED = 400.0
var velocity = Vector2.RIGHT # We'll set this when we fire it

func _physics_process(delta: float):
	# Move in our direction
	global_position += velocity * SPEED * delta

func _on_body_entered(body):
	# 'body' is what we hit. Is it in the "Enemy" group?
	if body.is_in_group("Enemy"):
		body.take_damage() # Kill the enemy
		queue_free() # Destroy ourselves (the bullet)
