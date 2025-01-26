extends Control

@export var fade: FadeScreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_close_credits() -> void:
	fade.connect("end_fade_signal",	_change_main_to_credits )
	fade.to_black()
	
func _change_main_to_credits():
	fade.disconnect("end_fade_signal", _change_main_to_credits)
	$PanelContainer.visible = false
	$MarginContainer.visible = true
	fade.to_white()

func _on_open_credits() -> void:
	fade.connect("end_fade_signal",	_change_credits_to_main )
	fade.to_black()
	
func _change_credits_to_main():
	fade.disconnect("end_fade_signal", _change_credits_to_main)
	$PanelContainer.visible = true
	$MarginContainer.visible = false
	fade.to_white()
	

func _on_exit_game() -> void:
	get_tree().quit()


func _on_init_game() -> void:
	fade.connect("end_fade_signal",	_init_game )
	fade.to_black()
	
func _init_game():
	fade.disconnect("end_fade_signal", _init_game)
	visible = false
	GameController.init_game()
	fade.to_white()
