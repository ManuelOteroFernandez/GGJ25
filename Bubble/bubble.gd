class_name Bubble
extends Node2D

@export var direction : Vector2 = Vector2(0,0)

@onready var sound_explota = load("res://Musica/1.Efectos de sonido/Pompa explota.mp3")
@onready var sound_union = load("res://Musica/1.Efectos de sonido/Fusion pompas.mp3")

var bubbleT: GameController.bubbleType = GameController.bubbleType.blue
# Numero de rebotes que puede resistir
var endurance: float = 0

func with_data(dir, type):
	direction = dir
	bubbleT = type
	$RigidBody2D/AnimatedSprite2D.modulate = GameController.bubbleColor[type]
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var collision = $RigidBody2D.move_and_collide(direction * delta)
	if collision:
		var collider = collision.get_collider() as Node
		if collider.is_in_group("Muro"):
			if  endurance > 0:
				bubbleT = GameController.bubbleType.blue
				$RigidBody2D/AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
				endurance = 0
			#elif not $Audio.playing:
				#$Audio.stream = sound_explota
				#$Audio.connect("finished",_sound_explotion_finish)
				#$Audio.play()
			else:
				queue_free()
				
		elif collider.is_in_group("Player"):
			queue_free()
		elif collider.is_in_group("Bubbles"):
			bubbleT = GameController.bubbleType.purple
			$RigidBody2D/AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
			endurance = 1
			$Audio.stream = sound_union
			$Audio.play()
			direction += (collider.get_parent() as Bubble).direction
			collider.get_parent().free()
		#print(endurance)

func changeType() -> void:
	if bubbleT == GameController.bubbleType.blue:
		bubbleT = GameController.bubbleType.purple
		$RigidBody2D/AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
		endurance = 1
	elif bubbleT == GameController.bubbleType.purple and endurance == 1:
		bubbleT = GameController.bubbleType.blue
		$RigidBody2D/AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
		endurance = 0
		
func _sound_explotion_finish():
	$Audio.disconnect("finished",_sound_explotion_finish)
	queue_free()
