class_name BubbleGenerator extends Node2D

@export var spawn_time:float = 1
@export var bubble_type:GameController.bubbleType = GameController.bubbleType.blue
@export var bubble_speed: Vector2 = Vector2(1,1)
@export var bubble_gravity_scale: float = 0.1

var scene_bubble = preload("res://Bubble/Bubble.tscn");

func _ready() -> void:
	$Timer.wait_time = spawn_time
	$Sprite2D.modulate = GameController.bubbleColor[bubble_type]

func spawn_bubble():
	
	var b = scene_bubble.instantiate()
	if bubble_type == GameController.bubbleType.blue:
		(b as Bubble).endurance = 0
	else: 
		(b as Bubble).endurance = 1
	
	(b as Bubble).gravity_scale = bubble_gravity_scale
	b.with_data(bubble_speed,bubble_type)
	$BubbleList.add_child(b)
	$AudioStreamPlayer2D.play()
	


func _on_timer_timeout() -> void:
	spawn_bubble()
