extends Node

# Sound Dictionary
var sounds = {
	"bgm": preload("res://audio/bgm.wav"),
	"victory": preload("res://audio/victory.wav"),
	"game_over": preload("res://audio/game_over.wav"),
	"level_up": preload("res://audio/level_up.wav"),
	
	"hero_shoot": [
		preload("res://audio/hero_shoot_1.wav"),
		preload("res://audio/hero_shoot_2.wav")
	],
	"hero_hit": [
		preload("res://audio/hero_hit_1.wav"),
		preload("res://audio/hero_hit_2.wav")
	],
	"enemy_hit": [
		preload("res://audio/enemy_hit_1.wav"),
		preload("res://audio/enemy_hit_2.wav"),
		preload("res://audio/enemy_hit_3.wav")
	],
	"enemy_die": [
		preload("res://audio/enemy_die_1.wav"),
		preload("res://audio/enemy_die_2.wav"),
		preload("res://audio/enemy_die_3.wav")
	],
	"enemy_spawn": [
		preload("res://audio/enemy_spawn_1.wav"),
		preload("res://audio/enemy_spawn_2.wav"),
		preload("res://audio/enemy_spawn_3.wav")
	],
	"xp_pickup": [
		preload("res://audio/xp_pickup_1.wav"),
		preload("res://audio/xp_pickup_2.wav")
	]
}

# Audio Players
var num_players = 12
var bus = "Master"
var available_players = []
var music_player: AudioStreamPlayer

static var instance = null

func _ready():
	if instance != null:
		print("WARNING: Duplicate SoundManager detected! Deleting self.")
		queue_free()
		return
	instance = self

	# Create the pool of SFX players
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available_players.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus
		
	# Create Music Player if not already created by lazy init
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
		music_player.bus = bus

func play_sfx(sound_name: String):
	if not sounds.has(sound_name):
		print("Sound not found: ", sound_name)
		return
		
	var sound_resource = sounds[sound_name]
	
	# Handle Arrays (Random variant)
	if sound_resource is Array:
		sound_resource = sound_resource.pick_random()
		
	# Find an available player
	var player = available_players.pop_back()
	if player:
		player.stream = sound_resource
		player.play()
	else:
		print("No audio players available for: ", sound_name)

func play_music(music_name: String):
	if not sounds.has(music_name): return
	
	if not music_player:
		music_player = AudioStreamPlayer.new()
		add_child(music_player)
		music_player.bus = bus
	
	if music_player.stream != sounds[music_name]:
		music_player.stream = sounds[music_name]
		music_player.play()
	elif not music_player.playing:
		music_player.play()

func stop_music():
	music_player.stop()

func _on_stream_finished(player):
	available_players.append(player)
