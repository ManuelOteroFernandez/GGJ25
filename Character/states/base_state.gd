@abstract
class_name BaseState
extends RefCounted

var character: Player

func _init(player: Player) -> void:
	character = player

@abstract
func on_start(data: Dictionary = {}) -> void
	
@abstract
func on_end() -> void

@abstract
func on_input(event: InputEvent) -> void

@abstract
func on_physics_process(delta: float) -> void

@abstract
func on_process(delta: float) -> void
