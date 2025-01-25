extends Node

# Enum para tipos de burbulla
enum bubbleType {
	blue, purple
}

#Diccionario de valores para a cor das burbullas
var bubbleColor = {bubbleType.blue: Color.CORNFLOWER_BLUE, bubbleType.purple: Color.PURPLE}

var last_checkpoint_position = Vector2(0,0)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("pause",true):
		get_tree().paused = not get_tree().paused
