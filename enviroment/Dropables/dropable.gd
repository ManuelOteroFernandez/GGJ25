extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Cando o xogador entre na área2D
	if body.is_in_group("Player"):
		# Cambiamos a máscara de colisión pra que ignore muros
		set_collision_mask_value(2, false)
		# Escollemos un valor aleatorio de impulso en x e o aplicamos ao obxeto 
		# nun punto descentrado pra forzar rotación
		var xImp = RandomNumberGenerator.new().randf_range(-5, 5)*100
		apply_impulse(Vector2(xImp, -100),Vector2(0, 1))
