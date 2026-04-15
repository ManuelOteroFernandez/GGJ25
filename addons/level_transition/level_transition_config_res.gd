@tool
class_name LevelTransitionConfigRes
extends Resource

## Editor-state resource persisted inside the plugin folder.
## Stores the dock configuration so it survives editor restarts.
## The generated LevelListRes (runtime) is saved to output_path by the plugin.
@export var lists: Dictionary = {}
@export var main_menu_path: String = ""
@export var output_path: String = "res://"
