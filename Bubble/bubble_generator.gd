class_name BubbleGenerator extends Node2D

@export var spawn_time:float = 1
@export var bubble_type:BubleTypeRes
@export var bubble_speed: Vector2 = Vector2(1,1)

var scene_bubble = preload("res://Bubble/Bubble.tscn");

func _ready() -> void:
	$Timer.wait_time = spawn_time
	$Sprite2D.modulate = bubble_type.color_array.back()
	spawn_bubble()
	$Timer.start()

func spawn_bubble():
	
	var b:Bubble = scene_bubble.instantiate()
	b.with_data(bubble_speed,bubble_type)
	$BubbleList.add_child(b)
	$AudioStreamPlayer2D.play()

func _on_timer_timeout() -> void:
	spawn_bubble()
