extends PanelContainer


@export var tmc: TransitionManagerClass

func _ready() -> void:
	GameController.pause_signal.connect(on_pause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	
func on_pause():
	var sm = get_tree().current_scene
	if sm is SceneManager:
		if (sm as SceneManager).is_open_main_menu():
			visible = false
			return
	
	if tmc.is_in_transition():
		get_tree().paused = true
		return
		
	if not get_tree().paused:
		visible = false
	else:
		tmc.mid_transition_signal.connect(self._on_mid_transition)
		tmc.start_transition(TransitionManagerClass.Transitions.FADE)

func _on_mid_transition():
	tmc.mid_transition_signal.disconnect(self._on_mid_transition)
	visible = true
	tmc.end_transition()
	

func _on_btn_continue_pressed() -> void:
	$Boton.play()
	GameController.pause(true,false)
