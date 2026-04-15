@tool
class_name LevelItemDock
extends HBoxContainer

@onready var _path_edit: LineEdit = $LineEditPath
@onready var _file_btn: Button = $BtnFile
@onready var _trash_btn: Button = $BtnTrash

var _file_dialog: EditorFileDialog


func _ready() -> void:
	_file_btn.icon = get_theme_icon("PackedScene", "EditorIcons")
	_trash_btn.icon = get_theme_icon("Remove", "EditorIcons")
	_setup_file_dialog()


func _setup_file_dialog() -> void:
	_file_dialog = EditorFileDialog.new()
	_file_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_file_dialog.add_filter("*.tscn,*.scn", "Scene Files")
	_file_dialog.file_selected.connect(_on_file_selected)
	add_child(_file_dialog)


func set_data(path: String) -> void:
	_path_edit.text = path


func get_data() -> String:
	return _path_edit.text.strip_edges()


func _on_file_selected(path: String) -> void:
	_path_edit.text = path


func _on_btn_file_button_up() -> void:
	_file_dialog.popup_centered_ratio(0.7)


func _on_btn_trash_button_up() -> void:
	queue_free()
