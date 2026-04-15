extends Control

const TRANSITION_TIME: float = 1

@onready var btn_continue: Button = $MainMenu/VBoxContainer3/BtnContinue

@onready var btn_close: TextureButton = $Credits/BtnClose

@onready var btn_audio: AudioStreamPlayer = $BtnAudio
@onready var color_rect: ColorRect = $ColorRect

@onready var main_menu: Control = $MainMenu
@onready var credits: Control = $Credits


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	btn_continue.visible = SaveSystem.get_level_index() > 0
	
	color_rect.fade_out(TRANSITION_TIME)


func _change_credits_to_main():
	credits.visible = false
	main_menu.visible = true

func _change_main_to_credits():
	credits.visible = true
	main_menu.visible = false


func _on_close_credits() -> void:
	btn_audio.play()
	await  color_rect.fade_in(TRANSITION_TIME)
	_change_credits_to_main()
	color_rect.fade_out(TRANSITION_TIME)


func _on_open_credits() -> void:
	btn_audio.play()
	await  color_rect.fade_in(TRANSITION_TIME)
	_change_main_to_credits()
	color_rect.fade_out(TRANSITION_TIME)


func _on_exit_game() -> void:
	btn_audio.play()
	get_tree().quit()


func _on_init_game() -> void:
	SaveSystem.set_level_index(0)
	SaveSystem.save_game()
	
	btn_audio.play()
	LevelTransition.current_level_index = -1
	LevelTransition.request_transition_next("expo")
	
func _on_continue_game():
	btn_audio.play()
	LevelTransition.current_level_index = SaveSystem.get_level_index()
	LevelTransition.request_transition_next("expo")
	
