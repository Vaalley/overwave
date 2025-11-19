extends Node

var ghost_scene = preload("res://ghost.tscn")

var valid_spawn_points: Array[Vector2]
var spawn_timer: Timer
var player: Node2D

@export var ground_layer: TileMapLayer

func _ready() -> void:
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = 1.0
	spawn_timer.timeout.connect(spawn_enemy)
	
	# Wait one frame to ensure the map and player are ready
	await get_tree().process_frame
	
	player = get_tree().get_first_node_in_group("Player")
	
	if ground_layer:
		_build_spawn_cache()
		spawn_timer.start()
	else:
		print("Error: No Ground Layer assigned to GameManager!")

func _build_spawn_cache() -> void:
	# Get every single tile coordinate used in the layer
	var tile_coords_array = ground_layer.get_used_cells() 
	var space_state = get_tree().root.world_2d.direct_space_state
	
	for coords in tile_coords_array:
		# Convert grid coords (e.g., 5, 5) to world pixels (e.g., 160, 160)
		var local_pos = ground_layer.map_to_local(coords)
		var global_pos = ground_layer.to_global(local_pos)
		
		# Check if the cell is in physics layer 1 (non-walkable)
		var query = PhysicsPointQueryParameters2D.new()
		query.position = global_pos
		query.collision_mask = 1  # Only check physics layer 1
		var result = space_state.intersect_point(query)
		
		# Only add spawn point if no collision found in physics layer 1
		if result.is_empty():
			valid_spawn_points.append(global_pos)
	
	print("Found ", valid_spawn_points.size(), " valid spawn tiles.")

func spawn_enemy() -> void:
	if valid_spawn_points.is_empty() or not player:
		return

	var spawn_pos = Vector2.ZERO
	var found_good_spot = false
	
	# Try 10 times to find a spot that is close to the player 
	# but NOT on screen (between 500 and 900 pixels away)
	for i in 10:
		var random_point = valid_spawn_points.pick_random()
		var distance = random_point.distance_to(player.global_position)
		
		if distance > 500 and distance < 900:
			spawn_pos = random_point
			found_good_spot = true
			break
	
	# If we couldn't find a perfect spot in 10 tries, just pick any random one
	if not found_good_spot:
		spawn_pos = valid_spawn_points.pick_random()
	
	# Create the ghost
	var ghost = ghost_scene.instantiate()
	ghost.global_position = spawn_pos
	get_tree().root.add_child(ghost)
