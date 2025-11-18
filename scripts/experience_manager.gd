extends Node

signal xp_changed(current_xp, xp_to_next_level)
signal level_up(new_level)

var current_xp = 0
var xp_to_next_level = 5
var current_level = 1

func add_xp(amount):
	current_xp += amount
	
	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		current_level += 1
		xp_to_next_level = int(xp_to_next_level * 1.5)
		
		level_up.emit(current_level)
	
	xp_changed.emit(current_xp, xp_to_next_level)
