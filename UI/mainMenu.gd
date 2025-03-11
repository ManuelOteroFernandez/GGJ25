extends Control

var tmc: TransitionManagerClass
var scene_manager: SceneManager

enum Actions { None, Credits_close , Credits_open, Game_start }

var action: Actions = Actions.None

func _ready() -> void:
	TranslationServer.set_locale("gal")
	process_mode = Node.PROCESS_MODE_ALWAYS
	scene_manager = get_tree().current_scene as SceneManager
	#Se espera que el TransitionManager este como segundo nodo de la escena
	tmc = scene_manager.tsm
	
	tmc.mid_transition_signal.connect(self._on_mid_transition)
	#tmc.end_transition_signal.connect(self._on_end_transition)

#func _on_end_transition():
	#pass

func _on_mid_transition():
	if action == Actions.Credits_close:
		_change_credits_to_main()
	elif action == Actions.Credits_open:
		_change_main_to_credits()
		

func _on_close_credits() -> void:
	$Boton.play()
	action = Actions.Credits_close
	tmc.start_transition()
	
func _change_credits_to_main():
	$PanelContainer.visible = false
	$MarginContainer.visible = true
	tmc.end_transition()

func _on_open_credits() -> void:
	$Boton.play()
	action = Actions.Credits_open
	tmc.start_transition()

func _change_main_to_credits():
	$PanelContainer.visible = true
	$MarginContainer.visible = false
	tmc.end_transition()

func _on_exit_game() -> void:
	$Boton.play()
	get_tree().quit()


func _on_init_game() -> void:
	$Boton.play()
	action = Actions.Game_start
	scene_manager.open_level(0)
	
