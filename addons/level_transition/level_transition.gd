class_name LevelTransitionClass
extends Node

## Autoload that orchestrates scene transitions.
##
## --- Game code integration ---
## Block input:   LevelTransition.transition_started.connect(func(): controller.enabled(false))
## Unblock input: LevelTransition.level_ready.connect(func(): controller.enabled(true))
##
## --- HUD integration (persistent autoload) ---
## LevelTransition.transition_out_requested.connect(_start_fade_out)  # then call notify_ready_for_scene_change()
## LevelTransition.transition_in_requested.connect(_start_fade_in)    # then call notify_transition_in_complete()
## LevelTransition.scene_changed.connect(_reconnect_panels)
##
## --- Triggering transitions ---
## LevelTransition.request_transition_direct("res://levels/level2.tscn")
## LevelTransition.request_transition_next()              # auto-detects current list
## LevelTransition.request_transition_next("world1")      # explicit list

# ---------------------------------------------------------------------------
# Signals
# ---------------------------------------------------------------------------

## Emitted before fade-out. Connect to disable player input.
signal transition_started

## Emitted to ask the HUD to perform its fade-out animation.
## After the animation finishes, call notify_ready_for_scene_change().
signal transition_out_requested

## Emitted right after change_scene_to_packed, before fade-in.
## The new scene's _ready() has already run at this point.
signal scene_changed

## Emitted to ask the HUD to perform its fade-in animation.
## After the animation finishes, call notify_transition_in_complete().
signal transition_in_requested

## Emitted once the transition is fully complete. Connect to re-enable player input.
signal level_ready

## Emitted when request_transition_next() is called but the current level is
## the last in the list. If main_menu_path is set the transition goes there;
## otherwise no scene change occurs and this signal fires so game code can react.
signal list_complete(list_name: String)

# ---------------------------------------------------------------------------
# Public state
# ---------------------------------------------------------------------------

var is_transitioning: bool = false
var current_list_name: String = ""
var current_level_index: int = -1

## Maximum seconds to wait for HUD callbacks before continuing automatically.
var transition_timeout: float = 5.0

## Path to the main menu scene. Read from LevelListRes at startup.
## Can be overridden at runtime.
var main_menu_path: String = ""

# ---------------------------------------------------------------------------
# Private state
# ---------------------------------------------------------------------------

var _level_list: LevelListRes = null
var _out_complete: bool = false
var _in_complete: bool = false

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

func _ready() -> void:
	var list_path: String = ProjectSettings.get_setting(
		"level_transition/level_list_path", ""
	)
	transition_timeout = ProjectSettings.get_setting(
		"level_transition/transition_timeout", 5.0
	)
	if not list_path.is_empty() and ResourceLoader.exists(list_path):
		_level_list = load(list_path)
		main_menu_path = _level_list.main_menu_path

# ---------------------------------------------------------------------------
# Public API — transition requests
# ---------------------------------------------------------------------------

## Transition directly to the main menu.
## Does nothing if main_menu_path is not set.
func request_transition_to_main_menu() -> void:
	if main_menu_path.is_empty():
		printerr("LevelTransition: main_menu_path is not set. Configure it in the Level Transition dock.")
		return
	current_list_name = ""
	current_level_index = -1
	request_transition_direct(main_menu_path)


## Request a transition to a specific scene by path.
func request_transition_direct(scene_path: String) -> void:
	if is_transitioning:
		return
	if not ResourceLoader.exists(scene_path):
		printerr("LevelTransition: scene not found → ", scene_path)
		return
	_do_transition(scene_path)


## Request a transition to the next level in a named list.
## If list_name is empty, uses current_list_name or auto-detects from scene_file_path.
func request_transition_next(list_name: String = "") -> void:
	if is_transitioning:
		return
	if _level_list == null:
		printerr(
			"LevelTransition: no LevelListRes loaded. ",
			"Set 'level_transition/level_list_path' in ProjectSettings."
		)
		return

	var effective_list := list_name if not list_name.is_empty() else current_list_name

	# Auto-detect list from current scene path when not set
	if effective_list.is_empty():
		var current_path := get_tree().current_scene.scene_file_path
		for lname: String in _level_list.lists.keys():
			var levels: Array = _level_list.lists[lname]
			if current_path in levels:
				effective_list = lname
				current_level_index = levels.find(current_path)
				break

	if effective_list.is_empty():
		printerr(
			"LevelTransition: current scene not found in any list. ",
			"Pass list_name explicitly or load the scene from its list path."
		)
		return

	if not _level_list.lists.has(effective_list):
		printerr("LevelTransition: list not found → ", effective_list)
		return

	var levels: Array = _level_list.lists[effective_list]
	var next_index := current_level_index + 1

	if next_index >= levels.size():
		list_complete.emit(effective_list)
		if not main_menu_path.is_empty():
			current_list_name = ""
			current_level_index = -1
			_do_transition(main_menu_path)
		return

	current_list_name = effective_list
	current_level_index = next_index
	_do_transition(levels[next_index])


func request_transition_reset():
	request_transition_direct(
		get_tree().current_scene.scene_file_path
	)

# ---------------------------------------------------------------------------
# Public API — HUD callbacks
# ---------------------------------------------------------------------------

## Call this from the HUD after the fade-out animation completes.
func notify_ready_for_scene_change() -> void:
	_out_complete = true


## Call this from the HUD after the fade-in animation completes.
func notify_transition_in_complete() -> void:
	_in_complete = true

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func get_level_count(list_name: String) -> int:
	if _level_list == null or not _level_list.lists.has(list_name):
		return 0
	return (_level_list.lists[list_name] as Array).size()

# ---------------------------------------------------------------------------
# Transition coroutine
# ---------------------------------------------------------------------------

func _do_transition(scene_path: String) -> void:
	is_transitioning = true
	_out_complete = false
	_in_complete = false

	transition_started.emit()
	transition_out_requested.emit()

	# Wait for HUD fade-out (or timeout fallback)
	var start_ms := Time.get_ticks_msec()
	var timeout_ms := transition_timeout * 1000.0
	while not _out_complete and (Time.get_ticks_msec() - start_ms) < timeout_ms:
		await get_tree().process_frame

	# Load the next scene asynchronously
	ResourceLoader.load_threaded_request(scene_path)
	var status := ResourceLoader.load_threaded_get_status(scene_path)
	while status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		await get_tree().process_frame
		status = ResourceLoader.load_threaded_get_status(scene_path)

	if status != ResourceLoader.THREAD_LOAD_LOADED:
		printerr("LevelTransition: failed to load scene → ", scene_path)
		is_transitioning = false
		return

	var packed: PackedScene = ResourceLoader.load_threaded_get(scene_path)
	get_tree().change_scene_to_packed(packed)
	# Wait one frame so the new scene's _ready() fires before we emit scene_changed
	await get_tree().process_frame

	scene_changed.emit()
	transition_in_requested.emit()

	# Wait for HUD fade-in (or timeout fallback)
	start_ms = Time.get_ticks_msec()
	while not _in_complete and (Time.get_ticks_msec() - start_ms) < timeout_ms:
		await get_tree().process_frame

	is_transitioning = false
	level_ready.emit()
