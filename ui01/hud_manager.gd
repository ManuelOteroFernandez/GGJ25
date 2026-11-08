extends Node

const FADE_DURATION := 1.5

var _transition_screen: TransitionScreen
var _canvas: CanvasLayer
var _pause_menu: Control
#var _my_touch_control: MyTouchControl


func _ready() -> void:
	LevelTransition.scene_changed.connect(_on_scene_changed)
	LevelTransition.transition_out_requested.connect(_on_transition_out_requested)
	LevelTransition.transition_in_requested.connect(_on_transition_in_requested)
	
	_canvas = CanvasLayer.new()
	_canvas.layer = 100
	add_child(_canvas)
	
	#if DisplayServer.is_touchscreen_available():
		#var touch_control_tscn: PackedScene = load("res://ui/tactil/touch_controls.tscn")
		#_my_touch_control = touch_control_tscn.instantiate()
		#add_child(_my_touch_control)


func _setup_fallback_transition() -> void:
	var ts := TransitionScreen.new()
	ts.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ts.color = Color.BLACK
	ts.z_index = 101 #if _monitor else 0
	_canvas.add_child(ts)
	_transition_screen = ts


func _on_transition_out_requested() -> void:
	if not _transition_screen:
		_setup_fallback_transition() 
		
	await _transition_screen.fade_in(FADE_DURATION)
		
	LevelTransition.notify_ready_for_scene_change()


func _on_transition_in_requested() -> void:
	if not _transition_screen:
		_setup_fallback_transition() 
		
	await _transition_screen.fade_out(FADE_DURATION)
	
	LevelTransition.notify_transition_in_complete()


func _on_scene_changed() -> void:
	pass


func show_pause_menu() -> void:	
	if not _pause_menu:
		_pause_menu = preload("res://ui/MenuPause.tscn").instantiate()
		_canvas.add_child(_pause_menu)

	_pause_menu.show_menu()


func hide_pause_menu() -> void:	
	if not _pause_menu:
		return
		
	await _pause_menu.hide_menu()
	_pause_menu.queue_free()
	_pause_menu = null
