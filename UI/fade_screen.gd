class_name FadeScreen extends ColorRect
signal end_fade_signal

@export var player:Player

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	player.connect("on_dead_signal",_on_player_dead)

func _on_player_dead():
	$AnimationPlayer.play("Respawn")
	
func to_black():
	$AnimationPlayer.play("to_black")
	
func to_white():
	$AnimationPlayer.play("fade")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	end_fade_signal.emit()
