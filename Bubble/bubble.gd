class_name Bubble
extends RigidBody2D

signal pop_signal

@export var direction : Vector2 = Vector2(0,0)

@onready var sound_explota = load("res://Musica/1.Efectos de sonido/Pompa explota.mp3")
@onready var sound_union = load("res://Musica/1.Efectos de sonido/Fusion pompas.mp3")

var bubbleT: BubleTypeRes
# Numero de rebotes que puede resistir
var endurance: float = 0

func _enter_tree() -> void:
	apply_force(direction)

func with_data(dir, type: BubleTypeRes):
	direction = dir
	bubbleT = type
	gravity_scale = type.gravity
	_change_endurance(type.endurance)
	
func pop() -> void:
	set_collision_layer_value(1,false)
	set_collision_layer_value(3,false)
	set_collision_mask_value(1,false)
	set_collision_mask_value(3,false)
	
	pop_signal.emit()
	queue_free()

		
func _sound_explotion_finish():
	$Audio.disconnect("finished",_sound_explotion_finish)
	
	pop_signal.emit()
	queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Muro"):
		if  endurance > 1:
			_change_endurance(-1)
		else:
			pop_signal.emit()
			queue_free()
			
	elif body.is_in_group("Bubbles"):
		_change_endurance(1)
		$Audio.stream = sound_union
		$Audio.play()
		apply_force(body.linear_velocity * get_process_delta_time())
		body.free()

func _change_endurance(delta:int):
	endurance = endurance + delta
	if endurance > bubbleT.endurance:
		endurance = bubbleT.endurance
	
	var color_index = ceili(bubbleT.color_array.size() * endurance/bubbleT.endurance) - 1
	$AnimatedSprite2D.modulate = bubbleT.color_array[color_index]
