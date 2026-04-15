@tool
extends Control

signal save_lists_signal(lists: Dictionary, main_menu_path: String, output_path: String)

const _CONFIG_RES_PATH = "res://addons/level_transition/level_transition_config.tres"

@onready var _list_container: VBoxContainer = $Panel/MarginContainer/ScrollContainer/VBoxContainer/ListContainer
@onready var _label_error: Label = $Panel/MarginContainer/ScrollContainer/VBoxContainer/LabelError
@onready var _path_edit: LineEdit = $Panel/MarginContainer/ScrollContainer/VBoxContainer/PathRow/LineEditPath
@onready var _folder_btn: Button = $Panel/MarginContainer/ScrollContainer/VBoxContainer/PathRow/BtnFolder
@onready var _menu_edit: LineEdit = $Panel/MarginContainer/ScrollContainer/VBoxContainer/MenuRow/LineEditMenu
@onready var _menu_btn: Button = $Panel/MarginContainer/ScrollContainer/VBoxContainer/MenuRow/BtnMenu

var _config_res: LevelTransitionConfigRes = (
	load(_CONFIG_RES_PATH) if ResourceLoader.exists(_CONFIG_RES_PATH)
	else LevelTransitionConfigRes.new()
)
var _list_item_scn := preload("res://addons/level_transition/dock/list_item.tscn")
var _file_dialog: EditorFileDialog
var _scene_dialog: EditorFileDialog


func _ready() -> void:
	_folder_btn.icon = get_theme_icon("Folder", "EditorIcons")
	_menu_btn.icon = get_theme_icon("PackedScene", "EditorIcons")
	_setup_file_dialog()
	_setup_scene_dialog()
	_show_data()


func _setup_file_dialog() -> void:
	_file_dialog = EditorFileDialog.new()
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_file_dialog.dir_selected.connect(_on_dir_selected)
	add_child(_file_dialog)


func _setup_scene_dialog() -> void:
	_scene_dialog = EditorFileDialog.new()
	_scene_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_scene_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_scene_dialog.add_filter("*.tscn,*.scn", "Scene Files")
	_scene_dialog.file_selected.connect(func(p: String): _menu_edit.text = p)
	add_child(_scene_dialog)


func _show_data() -> void:
	_path_edit.text = _config_res.output_path
	_menu_edit.text = _config_res.main_menu_path
	for lname: String in _config_res.lists.keys():
		var item: ListItemDock = _add_list_item()
		item.set_data(lname, _config_res.lists[lname])


func _add_list_item() -> ListItemDock:
	var item: ListItemDock = _list_item_scn.instantiate()
	_list_container.add_child(item)
	return item


func _on_btn_add_list_button_up() -> void:
	_add_list_item()


func _on_folder_button_up() -> void:
	_file_dialog.popup_centered_ratio(0.7)


func _on_menu_btn_button_up() -> void:
	_scene_dialog.popup_centered_ratio(0.7)


func _on_dir_selected(dir: String) -> void:
	_path_edit.text = dir


func _on_btn_save_button_up() -> void:
	_label_error.visible = false
	var lists: Dictionary = {}

	for item: ListItemDock in _list_container.get_children():
		var d := item.get_data()
		var lname := d["name"] as String
		var levels := d["levels"] as Array

		if lname.is_empty():
			_set_error("Error: el nombre de lista no puede estar vacío")
			return

		if lname in lists:
			_set_error("Error: nombre de lista duplicado → '%s'" % lname)
			return

		lists[lname] = levels

	var output_path := _path_edit.text.strip_edges()
	if output_path.is_empty():
		_set_error("Error: el output path no puede estar vacío")
		return

	save_lists_signal.emit(lists, _menu_edit.text.strip_edges(), output_path)
	_label_error.text = "Guardado correctamente"
	_label_error.modulate = Color(0.3, 1.0, 0.5, 1)
	_label_error.visible = true


func _set_error(msg: String) -> void:
	_label_error.modulate = Color(1, 0.3, 0.3, 1)
	_label_error.text = msg
	_label_error.visible = true
