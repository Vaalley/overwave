extends CanvasLayer

@onready var xp_bar = $XPBar

func _ready():
	ExperienceManager.xp_changed.connect(_on_xp_changed)
	ExperienceManager.level_up.connect(_on_level_up)
	
	xp_bar.value = ExperienceManager.current_xp
	xp_bar.max_value = ExperienceManager.xp_to_next_level

func _on_xp_changed(current_xp, xp_to_next_level):
	xp_bar.value = current_xp
	xp_bar.max_value = xp_to_next_level

func _on_level_up(_new_level):
	pass
