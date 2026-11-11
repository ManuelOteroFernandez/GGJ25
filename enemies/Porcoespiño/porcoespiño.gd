extends Area2D

@export var im_special:bool = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if body.has_method("dead"):
			body.dead(im_special)
