extends PanelContainer


@export var fade: FadeScreen

func _ready() -> void:
	GameController.pause_signal.connect(on_pause)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func on_pause():
	if not get_tree().paused:
		_continue_1()
	
	else:
		fade.connect("end_fade_signal",	_show_pause_menu )
		fade.to_black()

func _show_pause_menu():
	fade.disconnect("end_fade_signal", _show_pause_menu)
	visible = true
	fade.to_white()
	

func _on_btn_continue_pressed() -> void:
	GameController.pause()
	
func _continue_1():
	fade.connect("end_fade_signal",	_continue )
	fade.to_black()


func _continue() -> void:
	fade.disconnect("end_fade_signal", _continue)
	visible = false
	fade.to_white()
