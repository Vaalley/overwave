extends CanvasLayer

# Get references to our 3 buttons
@onready var button1 = $VBoxContainer/Button
@onready var button2 = $VBoxContainer/Button2
@onready var button3 = $VBoxContainer/Button3


func _ready():
	# 1. Listen for the global level_up signal
	ExperienceManager.level_up.connect(_on_level_up)
	
	# 2. Connect all 3 buttons to the same "choice_made" function
	button1.pressed.connect(_on_choice_made)
	button2.pressed.connect(_on_choice_made)
	button3.pressed.connect(_on_choice_made)


# This is the "INTERRUPT"
func _on_level_up(new_level):
	# Pause the entire game
	get_tree().paused = true
	# And show this screen
	self.visible = true


# This is the "CHOICE"
func _on_choice_made():
	# (Later, we'll apply the actual upgrade here)
	print("Upgrade Chosen!")
	
	# Un-pause the game
	get_tree().paused = false
	# And hide this screen
	self.visible = false
