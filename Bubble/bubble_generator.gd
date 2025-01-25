class_name BubbleGenerator extends Node2D

@export var spawn_time:float = 1
@export var bubble_type:GameController.bubbleType = GameController.bubbleType.blue
@export var bubble_speed: Vector2 = Vector2(1,1)

var scene_bubble = preload("res://Bubble/Bubble.tscn");

func _ready() -> void:
	$Timer.wait_time = spawn_time

func spawn_bubble():
	
	var b = scene_bubble.instantiate()
	b.position = position
	b.with_data(bubble_speed,bubble_type)
	$BubbleList.add_child(b)
	


func _on_timer_timeout() -> void:
	spawn_bubble()
