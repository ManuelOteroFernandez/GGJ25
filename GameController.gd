extends Node

signal pause_signal
signal init_game_signal
signal end_game_signal

# Enum para tipos de burbulla
enum bubbleType {
	blue, purple
}

#Diccionario de valores para a cor das burbullas
var bubbleColor = {bubbleType.blue: Color.CORNFLOWER_BLUE, bubbleType.purple: Color.PURPLE}

var last_checkpoint_position = Vector2(0,0)

var in_menu = true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = false

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("pause",true):
		pause()
		
func init_game():
	init_game_signal.emit()
	in_menu = false
	get_tree().paused = false
	
func pause():
	get_tree().paused = not get_tree().paused
	pause_signal.emit()
	
func end_game():
	last_checkpoint_position = Vector2(0,0)
	end_game_signal.emit()
	get_tree().paused = true
	
	
