extends Area2D

@onready var textureInactive: Texture2D = load("res://cousasescenario/checkpoint_active.png")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameController.last_checkpoint_position = position
		$CollisionShape2D/Sprite2D.texture = textureInactive
