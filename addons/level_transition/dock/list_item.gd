@tool
class_name ListItemDock
extends VBoxContainer

@onready var _name_edit: LineEdit = $HeaderRow/LineEditName
@onready var _trash_btn: Button = $HeaderRow/BtnTrash
@onready var _level_list: VBoxContainer = $LevelList

var _level_item_scn := preload("res://addons/level_transition/dock/level_item.tscn")


func _ready() -> void:
	_trash_btn.icon = get_theme_icon("Remove", "EditorIcons")


func set_data(list_name: String, paths: Array) -> void:
	_name_edit.text = list_name
	for path: String in paths:
		_add_level_item(path)


func get_data() -> Dictionary:
	var levels: Array[String] = []
	for child in _level_list.get_children():
		var path := (child as LevelItemDock).get_data()
		if not path.is_empty():
			levels.append(path)
	return {
		"name": _name_edit.text.strip_edges(),
		"levels": levels,
	}


func _add_level_item(path: String = "") -> void:
	var item: LevelItemDock = _level_item_scn.instantiate()
	_level_list.add_child(item)
	if not path.is_empty():
		item.set_data(path)


func _on_btn_add_level_button_up() -> void:
	_add_level_item()


func _on_btn_trash_button_up() -> void:
	queue_free()
