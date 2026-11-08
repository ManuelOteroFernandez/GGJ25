extends PanelContainer



func _ready() -> void:
	GameController.pause_signal.connect(on_pause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	
func on_pause():
	if get_tree().paused:
		show()
	else:
		hide()

	

func _on_btn_continue_pressed() -> void:
	$Boton.play()
	GameController.pause(true,false)
