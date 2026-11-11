extends Node2D

@export var roll_distance: float = 200.0
@export var roll_duration: float = 1.5
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _current_anim = ""


func _ready() -> void:
	notifier.screen_entered.connect(_on_screen_entered)


func _on_screen_entered() -> void:
	if animation_player.is_playing():
		return 
		
	var reverse = _current_anim != ""
	if _current_anim == "":
		_current_anim = Array(animation_player.get_animation_list()).pick_random()
	
	animation_player.play(
		_current_anim,
		-1,
		-1.0 if reverse else 1.0,
		reverse
	)
	
	if reverse:
		_current_anim = ""
	
