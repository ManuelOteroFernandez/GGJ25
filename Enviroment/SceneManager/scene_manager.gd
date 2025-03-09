class_name SceneManager extends Node

@export var transition = TransitionManagerClass.Transitions.FADE

@onready var main_menu = preload("res://UI/MainMenu.tscn")
@onready var tsm : TransitionManagerClass = $UI/TransitionManager

signal open_level_end

enum Transition_to { None, MainMenu, Level }

var next_scene = null
var current_transition = Transition_to.None
var current_level_index = 0

const level_list = [
	"res://Test/Test_level.tscn",
	"res://Enviroment/Nivel1.tscn"
]

func _ready() -> void:
	tsm.mid_transition_signal.connect(self._on_mid_transition)
	tsm.mid_transition_signal.connect(self._on_end_transition)
	open_main_menu()

func open_level(level_index:int):
	
	if level_index < len(level_list):
		GameController.pause(true, true)
		next_scene = level_list[level_index]
		current_level_index = level_index
		current_transition = Transition_to.Level
		tsm.start_transition(transition)
	else:
		current_level_index = 0
		open_main_menu()

func open_next_level():
	open_level(current_level_index+1)

func open_main_menu():
	GameController.pause(true, true)
	tsm.end_transition(transition)
	current_transition = Transition_to.MainMenu
	$CurrentSceneStack.get_child(0).queue_free()
	$CurrentSceneStack.add_child(main_menu.instantiate())
	
func _on_mid_transition():
	tsm.end_transition()
	
	if current_transition == Transition_to.Level:
		$CurrentSceneStack.get_child(0).queue_free()
		var scene_node:Node = load(next_scene).instantiate()
		$CurrentSceneStack.add_child(scene_node)
		$CurrentSceneStack.move_child(scene_node,0)

func _on_end_transition():
	if current_transition != Transition_to.None:
		next_scene = null
		current_transition = Transition_to.None
		GameController.pause(true, false)
		open_level_end.emit()
		
func is_open_main_menu():
	var current_level_path = $CurrentSceneStack.get_child(0).scene_file_path
	return current_level_path == main_menu.resource_path or current_level_path == ""
