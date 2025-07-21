extends AudioStreamPlayer2D


@onready var sound_wall = load("res://Musica/1.Efectos de sonido/Arrastre pared.mp3")
@onready var sound_landing = load("res://Musica/1.Efectos de sonido/Aterrizar.mp3")
@onready var sound_in_bubble = load("res://Musica/1.Efectos de sonido/Gato entra en pompa.mp3")
@onready var sound_dead_especial = load("res://Musica/1.Efectos de sonido/Gato muere por hélice.mp3")
@onready var sound_dead = load("res://Musica/1.Efectos de sonido/Gato muere.mp3")
@onready var sound_jump = load("res://Musica/1.Efectos de sonido/Saltar.mp3")
@onready var sound_step = load("res://Musica/1.Efectos de sonido/Paso.mp3")


var parent

func _ready() -> void:
	parent = get_parent()


func _process(_delta: float) -> void:
	if parent == null: return
	
	if parent.anim_state == parent.ANIM_STATE_SET.WALL:
		play_sound(sound_wall)
	
	if parent.anim_state != parent.ANIM_STATE_SET.WALL and playing and stream == sound_wall:
		stop()


func play_sound(sound:AudioStream):
	if (not playing and stream == sound) or stream != sound:
		stream = sound
		play()
