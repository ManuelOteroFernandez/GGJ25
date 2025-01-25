extends Node

# Enum para tipos de burbulla
enum bubbleType {
	blue, purple
}

#Diccionario de valores para a cor das burbullas
var bubbleColor = {bubbleType.blue: Color.CORNFLOWER_BLUE, bubbleType.purple: Color.PURPLE}

var last_checkpoint_position = Vector2(0,0)
