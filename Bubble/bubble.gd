class_name Bubble
extends RigidBody2D

@export var direction : Vector2 = Vector2(0,0)

@onready var sound_explota = load("res://Musica/1.Efectos de sonido/Pompa explota.mp3")
@onready var sound_union = load("res://Musica/1.Efectos de sonido/Fusion pompas.mp3")

var bubbleT: GameController.bubbleType = GameController.bubbleType.blue
# Numero de rebotes que puede resistir
var endurance: float = 0

func with_data(dir, type):
	direction = dir
	bubbleT = type
	$AnimatedSprite2D.modulate = GameController.bubbleColor[type]
	

# Called when the node enters the scene tree for the first time.
func pop() -> void:
	set_collision_layer_value(1,false)
	set_collision_layer_value(3,false)
	set_collision_mask_value(1,false)
	set_collision_mask_value(3,false)
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * delta)
	if collision:
		var collider = collision.get_collider() as Node
		if collider.is_in_group("Muro"):
			if  endurance > 0:
				bubbleT = GameController.bubbleType.blue
				$AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
				endurance = 0
			else:
				queue_free()
				
		elif collider.is_in_group("Bubbles"):
			bubbleT = GameController.bubbleType.purple
			$AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
			endurance = 1
			$Audio.stream = sound_union
			$Audio.play()
			direction += (collider as Bubble).direction
			collider.free()

func changeType() -> void:
	if bubbleT == GameController.bubbleType.blue:
		bubbleT = GameController.bubbleType.purple
		$AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
		endurance = 1
	elif bubbleT == GameController.bubbleType.purple and endurance == 1:
		bubbleT = GameController.bubbleType.blue
		$AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
		endurance = 0
		
func _sound_explotion_finish():
	$Audio.disconnect("finished",_sound_explotion_finish)
	queue_free()
