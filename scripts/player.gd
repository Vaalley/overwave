class_name Player extends CharacterBody2D


const SPEED = 100.0

func _ready() -> void:
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	# Get the input direction for all four directions (left, right, up, down)
	var direction := Input.get_vector("left", "right", "up", "down")
	# Move the player
	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		velocity.y = move_toward(velocity.y, 0, SPEED * delta)

	move_and_slide()
