class_name MyTouchControl
extends CanvasLayer


func _ready() -> void:
	GameController.pause_signal.connect(_on_pause)
	LevelTransition.level_ready.connect(_show_tatil_btns)
	LevelTransition.scene_changed.connect(_hide_tatil_btns)


func _show_tatil_btns():
	visible = true


func _hide_tatil_btns():
	visible = false


func _on_pause():
	visible = not get_tree().paused
