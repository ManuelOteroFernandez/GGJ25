extends AudioStreamPlayer2D


@onready var sound_wall = load("res://character/sfx/Arrastre pared.mp3")
@onready var sound_landing = load("res://character/sfx/Aterrizar.mp3")
@onready var sound_in_bubble = load("res://character/sfx/Gato entra en pompa.mp3")
@onready var sound_dead_especial = load("res://Character/sfx/dead/Gato muere por hélice.mp3")
@onready var sound_dead = load("res://Character/sfx/dead/Gato muere.mp3")
@onready var sound_jump = load("res://Character/sfx/Saltar.mp3")
@onready var sound_step = load("res://Character/sfx/Paso.mp3")


var parent

func _ready() -> void:
	parent = get_parent()


func _process(_delta: float) -> void:
	if parent == null: return
	
	if parent.anim_state == parent.ANIM_STATE_SET.SLICE:
		play_sound(sound_wall)
	
	if parent.anim_state != parent.ANIM_STATE_SET.SLICE and playing and stream == sound_wall:
		stop()


func play_sound(sound:AudioStream):
	if (not playing and stream == sound) or stream != sound:
		stream = sound
		play()
