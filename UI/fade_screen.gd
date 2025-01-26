class_name FadeScreen extends ColorRect
signal end_fade_signal

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func to_black():
	$AnimationPlayer.play("to_black")
	
func to_white():
	$AnimationPlayer.play("fade")

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	end_fade_signal.emit()
