extends CanvasLayer

var sm:SceneManager

func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		queue_free()
	else:
		GameController.pause_signal.connect(_on_pause)
		var parent = get_tree().current_scene
		if parent is SceneManager:
			sm = (parent as SceneManager)
			sm.open_level_end.connect(_on_open_level_end)

func _on_open_level_end():
	visible = not sm.is_open_main_menu()

func _on_pause():
	var is_open_main_menu = sm.is_open_main_menu() if sm else true
	visible = not get_tree().paused and not is_open_main_menu
