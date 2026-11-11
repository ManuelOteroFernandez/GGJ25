@tool
extends EditorPlugin

const _CONFIG_PATH = "res://addons/level_transition/level_transition_config.tres"
const _AUTOLOAD_NAME = "LevelTransition"
const _AUTOLOAD_PATH = "res://addons/level_transition/level_transition.gd"
const _SETTING_LIST_PATH = "level_transition/level_list_path"
const _SETTING_TIMEOUT = "level_transition/transition_timeout"

var _config: LevelTransitionConfigRes
var _dock


func _enable_plugin() -> void:
	add_autoload_singleton(_AUTOLOAD_NAME, _AUTOLOAD_PATH)
	if not ProjectSettings.has_setting(_SETTING_LIST_PATH):
		ProjectSettings.set_setting(_SETTING_LIST_PATH, "")
		ProjectSettings.add_property_info({
			"name": _SETTING_LIST_PATH,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.tres",
		})
	if not ProjectSettings.has_setting(_SETTING_TIMEOUT):
		ProjectSettings.set_setting(_SETTING_TIMEOUT, 5.0)
		ProjectSettings.add_property_info({
			"name": _SETTING_TIMEOUT,
			"type": TYPE_FLOAT,
		})
	ProjectSettings.save()


func _disable_plugin() -> void:
	remove_autoload_singleton(_AUTOLOAD_NAME)


func _enter_tree() -> void:
	if ResourceLoader.exists(_CONFIG_PATH):
		_config = load(_CONFIG_PATH)
	else:
		_config = LevelTransitionConfigRes.new()
		ResourceSaver.save(_config, _CONFIG_PATH)

	_dock = preload("res://addons/level_transition/dock/level_transition_dock.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _dock)
	_dock.save_lists_signal.connect(_on_save_lists)


func _exit_tree() -> void:
	remove_control_from_docks(_dock)
	_dock.free()


func _on_save_lists(lists: Dictionary, main_menu_path: String, output_path: String) -> void:
	_config.lists = lists
	_config.main_menu_path = main_menu_path
	_config.output_path = output_path
	ResourceSaver.save(_config, _CONFIG_PATH)

	# Generate the runtime LevelListRes outside the plugin folder
	var runtime_res := LevelListRes.new()
	runtime_res.lists = lists
	runtime_res.main_menu_path = main_menu_path
	var save_path := output_path.path_join("level_list.tres")
	ResourceSaver.save(runtime_res, save_path)

	# Point the autoload to the generated resource
	ProjectSettings.set_setting(_SETTING_LIST_PATH, save_path)
	ProjectSettings.save()
