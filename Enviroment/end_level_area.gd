@tool
extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var shape: RectangleShape2D:
	set(value):
		shape = value
		if not is_node_ready():
			return
		collision_shape_2d.shape = shape


func _ready() -> void:
	shape = shape


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameController.end_game()
