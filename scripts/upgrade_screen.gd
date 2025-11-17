extends CanvasLayer

# We'll drag our.tres files here in the Inspector
@export var all_upgrades: Array

# Get references to our 3 buttons
@onready var button1 = $VBoxContainer/Button
@onready var button2 = $VBoxContainer/Button2
@onready var button3 = $VBoxContainer/Button3


func _ready():
	# 1. Listen for the global level_up signal
	ExperienceManager.level_up.connect(_on_level_up)
	
	# We "bind" the button itself to the function
	# so we know which one was clicked.
	button1.pressed.connect(_on_choice_made.bind(button1))
	button2.pressed.connect(_on_choice_made.bind(button2))
	button3.pressed.connect(_on_choice_made.bind(button3))


# This is the "INTERRUPT"
func _on_level_up(_new_level):
	# Pause the entire game
	get_tree().paused = true
	# And show this screen
	self.visible = true

	# Shuffle the list and pick the first 3 (or 2, if you only made 2)
	all_upgrades.shuffle()
	var choices = all_upgrades.slice(0, 2) # Or.slice(0, 2)
	
	# Set button text from our new resources
	button1.text = choices[0].name
	button2.text = choices[1].name
	#button3.text = choices[2].name # (Uncomment if you made 3)
	
	# IMPORTANT: "Attach" the actual upgrade data to the button
	button1.set_meta("upgrade", choices[0])
	button2.set_meta("upgrade", choices[1])
	#button3.set_meta("upgrade", choices[2]) # (Uncomment if you made 3)


# The "button_pressed" argument comes from our.bind()
func _on_choice_made(button_pressed: Button):
	
	# Get the upgrade data we attached
	var upgrade_chosen: UpgradeData = button_pressed.get_meta("upgrade")
	
	# --- ADD THIS ---
	# Tell the Player to apply this upgrade
	get_tree().get_first_node_in_group("Player").apply_upgrade(upgrade_chosen)
	# -----------------
	
	get_tree().paused = false
	self.visible = false
