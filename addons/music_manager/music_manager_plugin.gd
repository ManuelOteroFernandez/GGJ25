@tool
extends EditorPlugin

const _AUTOLOAD_NAME := "MusicManager"
const _AUTOLOAD_PATH := "res://addons/music_manager/music_manager.gd"
const _SETTING_PITCH := "music_manager/pitch_follows_time_scale"


func _enable_plugin() -> void:
	add_autoload_singleton(_AUTOLOAD_NAME, _AUTOLOAD_PATH)
	_register_settings()
	ProjectSettings.save()


func _disable_plugin() -> void:
	remove_autoload_singleton(_AUTOLOAD_NAME)


func _enter_tree() -> void:
	_register_settings()


func _exit_tree() -> void:
	pass


# ---------------------------------------------------------------------------
# Project Settings registration
# ---------------------------------------------------------------------------

func _register_settings() -> void:
	if not ProjectSettings.has_setting(_SETTING_PITCH):
		ProjectSettings.set_setting(_SETTING_PITCH, false)
		ProjectSettings.add_property_info({
			"name": _SETTING_PITCH,
			"type": TYPE_BOOL,
		})
