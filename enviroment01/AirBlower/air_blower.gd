extends Node2D

@export var direction : Vector2
@export var force : int = 980

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.gravity_direction = direction
	$Area2D.gravity = force


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
