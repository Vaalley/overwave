class_name Player extends CharacterBody2D


const SPEED = 100.0

var projectile_scene = preload("res://projectile.tscn")

func _ready() -> void:
	add_to_group("Player")
	
	$FireTimer.timeout.connect(_on_fire_timer_timeout)

func _physics_process(delta: float) -> void:
	# Get the input direction for all four directions (left, right, up, down)
	var direction := Input.get_vector("left", "right", "up", "down")
	# Move the player
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_fire_timer_timeout():
	# Create an instance of the bullet
	var p = projectile_scene.instantiate()
	
	# Set its starting position to where the player is
	p.global_position = global_position
	
	# (We'll aim it later. For now, just fire right)
	p.velocity = Vector2.RIGHT 
	
	# Add the bullet to the main game, NOT the player
	# This is so it doesn't move with the player
	get_tree().root.add_child(p)
