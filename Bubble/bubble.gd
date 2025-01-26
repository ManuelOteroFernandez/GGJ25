class_name Bubble
extends Node2D

@export var direction : Vector2 = Vector2(0,0)
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
			else:
				queue_free()
		elif collider.is_in_group("Player"):
			queue_free()
		elif collider.is_in_group("Bubbles"):
			bubbleT = GameController.bubbleType.purple
			$RigidBody2D/AnimatedSprite2D.modulate = GameController.bubbleColor[bubbleT]
			endurance = 1
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
		

#func onCollisionEnter(body: Node) -> void:
	#if body.is_in_group("Player") or body.is_in_group("Muro"):
		#print("patata")
		#queue_free()
	#if body.is_in_group("Bubbles"):
		#endurance += (body.get_parent() as Bubble).endurance
		#direction += (body.get_parent() as Bubble).direction
		#bubbleT = GameController.bubbleType.purple
		#body.get_parent().free()


#func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()
