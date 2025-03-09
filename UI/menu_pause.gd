extends PanelContainer


@export var tmc: TransitionManagerClass

func _ready() -> void:
	GameController.pause_signal.connect(on_pause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	tmc.mid_transition_signal.connect(self._on_mid_transition)
	
func on_pause():
	if tmc.is_in_transition():
		get_tree().paused = true
		return
		
	if not get_tree().paused:
		visible = false
	else:
		tmc.start_transition(TransitionManagerClass.Transitions.FADE)

func _on_mid_transition():
	visible = true
	tmc.end_transition()
	

func _on_btn_continue_pressed() -> void:
	$Boton.play()
	GameController.pause(true,false)
