extends Area2D

@onready var textureInactive: Texture2D = load("res://cousasescenario/checkpoint_active.png")

var actived = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not actived:
		actived = true
		$AudioStreamPlayer2D.play()
		GameController.last_checkpoint_position = global_position
		$CollisionShape2D/Sprite2D.texture = textureInactive
