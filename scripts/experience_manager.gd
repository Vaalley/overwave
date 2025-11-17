extends Node

# Signals to update UI
signal xp_changed(current_xp, xp_to_next_level)
signal level_up(new_level)

var current_xp = 0
var xp_to_next_level = 5 # Start by needing 5 XP
var current_level = 1

func add_xp(amount):
	current_xp += amount
	
	# Use 'while' in case we get enough XP for multiple levels
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		# Make the next level require more XP (simple scaling)
		xp_to_next_level = int(xp_to_next_level * 1.5)
		
		# Send the "level up" signal!
		level_up.emit(current_level)
	
	# Send the "xp changed" signal so the bar can update
	xp_changed.emit(current_xp, xp_to_next_level)
