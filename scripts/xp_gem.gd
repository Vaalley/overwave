extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		
		# (Later, this will be: ExperienceManager.add_xp(1))
		print("XP COLLECTED!")
		
		queue_free()
