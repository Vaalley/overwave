extends Area2D

func _ready():
	add_to_group("XPGem")

func _on_body_entered(body):
	if body.is_in_group("Hero"):
		if body.has_method("add_xp"):
			body.add_xp(1)
		queue_free()
