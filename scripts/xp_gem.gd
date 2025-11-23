extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# TODO: Add XP progression to player?
		print("Hero picked up a shiny rock.")
		queue_free()
