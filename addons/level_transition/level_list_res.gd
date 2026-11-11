@tool
class_name LevelListRes
extends Resource

## Runtime resource loaded by the LevelTransition autoload.
## Maps list names to ordered arrays of scene paths.
## Example: { "world1": ["res://levels/l1.tscn", "res://levels/l2.tscn"] }
@export var lists: Dictionary = {}
@export var main_menu_path: String = ""
