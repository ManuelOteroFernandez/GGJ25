class_name Bubble
extends Node2D

@export var direction : Vector2 = Vector2(0,0)
var bubbleT: GameController.bubbleType = GameController.bubbleType.blue
# Numero de rebotes que puede resistir
var endurance: float = 0

func with_data(dir, type):
	direction = dir
	bubbleT = type
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
		$RigidBody2D.move_and_collide(direction * delta)


func onCollisionEnter(body: Node) -> void:
	if body.is_in_group("Player"):
		queue_free()
	if body.is_in_group("Bubbles"):
		endurance += (body.get_parent() as Bubble).endurance
		direction += (body.get_parent() as Bubble).direction
		bubbleT = GameController.bubbleType.purple
		body.get_parent().free()
		


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
