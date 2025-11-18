extends Area2D

const SPEED = 400.0
var velocity = Vector2.RIGHT

func _physics_process(delta: float):
	global_position += velocity * SPEED * delta

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage()
		queue_free()
